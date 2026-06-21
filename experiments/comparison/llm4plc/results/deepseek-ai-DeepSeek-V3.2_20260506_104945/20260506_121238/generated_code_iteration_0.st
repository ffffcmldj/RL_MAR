START_ST
FUNCTION_BLOCK PouchMachine
VAR_INPUT
    start_machine: BOOL;
    stop_machine: BOOL;
    tension_established: BOOL; // Feedback that winding tension is properly established
    heating_active_fb: BOOL; // Feedback that all heating stations are active
    cooling_active_fb: BOOL; // Feedback that all cooling stations are active
    feeders_active_fb: BOOL; // Feedback that both feeder units are running
    cutters_active_fb: BOOL; // Feedback that both cutters are active
END_VAR

VAR_OUTPUT
    machine_ready: BOOL;
    feeder_running: BOOL;
    cutter_running: BOOL;
    heating_running: BOOL;
    cooling_running: BOOL;
    state: INT; // Expose current state for monitoring
END_VAR

VAR
    startup_complete: BOOL := FALSE;
    shutdown_complete: BOOL := FALSE;
    currentState: INT := 0; // 0=IDLE, 1=ACTIVATE_HEATING_COOLING, 2=START_FEEDERS_AND_TENSION, 3=ACTIVATE_CUTTERS, 4=READY, 5=DEACTIVATE_CUTTERS, 6=STOP_FEEDERS, 7=DEACTIVATE_HEATING_COOLING, 8=NOT_READY
    prevState: INT := 0;
    stateTimer: TON; // Timer for state transitions if needed
    stateTimerPreset: TIME := T#2s; // Example preset time for state transitions
END_VAR

END_FUNCTION_BLOCK

FUNCTION_BLOCK PouchMachine
VAR_INPUT
    start_machine: BOOL;
    stop_machine: BOOL;
    tension_established: BOOL;
    heating_active_fb: BOOL;
    cooling_active_fb: BOOL;
    feeders_active_fb: BOOL;
    cutters_active_fb: BOOL;
END_VAR

VAR_OUTPUT
    machine_ready: BOOL;
    feeder_running: BOOL;
    cutter_running: BOOL;
    heating_running: BOOL;
    cooling_running: BOOL;
    state: INT;
END_VAR

VAR
    startup_complete: BOOL := FALSE;
    shutdown_complete: BOOL := FALSE;
    currentState: INT := 0;
    prevState: INT := 0;
    stateTimer: TON;
    stateTimerPreset: TIME := T#2s;
END_VAR

// Main state machine logic
IF prevState <> currentState THEN
    // State changed, reset timer
    stateTimer(IN:=FALSE, PT:=stateTimerPreset);
    prevState := currentState;
END_IF;

stateTimer(IN:=TRUE, PT:=stateTimerPreset);

CASE currentState OF
    0: // IDLE - Machine not ready, all outputs off
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        startup_complete := FALSE;
        shutdown_complete := FALSE;
        
        IF start_machine AND NOT stop_machine THEN
            currentState := 1; // Transition to ACTIVATE_HEATING_COOLING
        END_IF;
        
    1: // ACTIVATE_HEATING_COOLING - Turn on heating and cooling stations
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := TRUE; // Command heating stations on
        cooling_running := TRUE; // Command cooling stations on
        
        // Wait for feedback confirmation that both heating and cooling are active
        IF heating_active_fb AND cooling_active_fb AND stateTimer.Q THEN
            currentState := 2; // Transition to START_FEEDERS_AND_TENSION
        END_IF;
        
    2: // START_FEEDERS_AND_TENSION - Start both feeder units and establish winding tension
        machine_ready := FALSE;
        feeder_running := TRUE; // Command feeders on
        cutter_running := FALSE;
        heating_running := TRUE;
        cooling_running := TRUE;
        
        // Wait for feedback that feeders are running AND tension is established
        IF feeders_active_fb AND tension_established AND stateTimer.Q THEN
            currentState := 3; // Transition to ACTIVATE_CUTTERS
        END_IF;
        
    3: // ACTIVATE_CUTTERS - Activate horizontal and vertical cutters
        machine_ready := FALSE;
        feeder_running := TRUE;
        cutter_running := TRUE; // Command cutters on
        heating_running := TRUE;
        cooling_running := TRUE;
        
        // Wait for feedback that cutters are active
        IF cutters_active_fb AND stateTimer.Q THEN
            currentState := 4; // Transition to READY
        END_IF;
        
    4: // READY - Machine running normally, all outputs on
        machine_ready := TRUE;
        feeder_running := TRUE;
        cutter_running := TRUE;
        heating_running := TRUE;
        cooling_running := TRUE;
        startup_complete := TRUE;
        
        IF stop_machine THEN
            currentState := 5; // Transition to DEACTIVATE_CUTTERS
        END_IF;
        
    5: // DEACTIVATE_CUTTERS - Stop both cutters
        machine_ready := FALSE;
        feeder_running := TRUE;
        cutter_running := FALSE; // Command cutters off
        heating_running := TRUE;
        cooling_running := TRUE;
        
        // Wait for feedback that cutters are stopped
        IF NOT cutters_active_fb AND stateTimer.Q THEN
            currentState := 6; // Transition to STOP_FEEDERS
        END_IF;
        
    6: // STOP_FEEDERS - Stop both feeder units
        machine_ready := FALSE;
        feeder_running := FALSE; // Command feeders off
        cutter_running := FALSE;
        heating_running := TRUE;
        cooling_running := TRUE;
        
        // Wait for feedback that feeders are stopped
        IF NOT feeders_active_fb AND stateTimer.Q THEN
            currentState := 7; // Transition to DEACTIVATE_HEATING_COOLING
        END_IF;
        
    7: // DEACTIVATE_HEATING_COOLING - Turn off heating and cooling stations
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := FALSE; // Command heating stations off
        cooling_running := FALSE; // Command cooling stations off
        
        // Wait for feedback that both heating and cooling are off
        IF NOT heating_active_fb AND NOT cooling_active_fb AND stateTimer.Q THEN
            currentState := 8; // Transition to NOT_READY
        END_IF;
        
    8: // NOT_READY - Machine fully stopped, all outputs off
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        shutdown_complete := TRUE;
        
        // Automatic transition back to IDLE after shutdown complete
        currentState := 0;
        
END_CASE;

// Expose current state for monitoring
state := currentState;

END_FUNCTION_BLOCK
END_ST