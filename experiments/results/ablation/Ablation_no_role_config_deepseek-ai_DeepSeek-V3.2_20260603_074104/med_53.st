FUNCTION_BLOCK PouchMachine
VAR_INPUT
    start_machine: BOOL;
    stop_machine: BOOL;
END_VAR

VAR_OUTPUT
    machine_ready: BOOL;
    feeder_running: BOOL;
    cutter_running: BOOL;
    heating_running: BOOL;
    cooling_running: BOOL;
END_VAR

VAR
    startup_complete: BOOL := FALSE;
    shutdown_complete: BOOL := FALSE;
    current_state: INT := 0;
    next_state: INT := 0;
    
    // Timers for state transitions
    heating_timer: TON;
    cooling_timer: TON;
    feeder_timer: TON;
    cutter_timer: TON;
    
    // Additional internal variables
    tension_established: BOOL;
    heating_stations_active: ARRAY[1..8] OF BOOL;
    cooling_stations_active: ARRAY[1..8] OF BOOL;
    horizontal_cutter_active: BOOL;
    vertical_cutter_active: BOOL;
    feeder1_active: BOOL;
    feeder2_active: BOOL;
    
    // Loop counter
    i: INT;
END_VAR

// Initialize timers with preset times
heating_timer(IN := FALSE, PT := T#2S);
cooling_timer(IN := FALSE, PT := T#2S);
feeder_timer(IN := FALSE, PT := T#3S);
cutter_timer(IN := FALSE, PT := T#1S);

CASE current_state OF
    0: (* Idle State *)
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        startup_complete := FALSE;
        shutdown_complete := FALSE;
        tension_established := FALSE;
        
        // Reset all stations
        FOR i := 1 TO 8 DO
            heating_stations_active[i] := FALSE;
            cooling_stations_active[i] := FALSE;
        END_FOR;
        
        horizontal_cutter_active := FALSE;
        vertical_cutter_active := FALSE;
        feeder1_active := FALSE;
        feeder2_active := FALSE;
        
        // Reset all timers
        heating_timer(IN := FALSE);
        cooling_timer(IN := FALSE);
        feeder_timer(IN := FALSE);
        cutter_timer(IN := FALSE);
        
        // Transition to start sequence
        IF start_machine AND NOT stop_machine THEN
            next_state := 1;
        ELSE
            next_state := 0;
        END_IF;
        
    1: (* Start Heating Stations *)
        heating_running := TRUE;
        
        // Activate all 8 heating stations
        FOR i := 1 TO 8 DO
            heating_stations_active[i] := TRUE;
        END_FOR;
        
        // Start timer for heating stabilization
        heating_timer(IN := TRUE);
        IF heating_timer.Q THEN
            next_state := 2;
            heating_timer(IN := FALSE);
        ELSE
            next_state := 1;
        END_IF;
        
    2: (* Start Cooling Stations *)
        cooling_running := TRUE;
        
        // Activate all 8 cooling stations
        FOR i := 1 TO 8 DO
            cooling_stations_active[i] := TRUE;
        END_FOR;
        
        // Start timer for cooling stabilization
        cooling_timer(IN := TRUE);
        IF cooling_timer.Q THEN
            next_state := 3;
            cooling_timer(IN := FALSE);
        ELSE
            next_state := 2;
        END_IF;
        
    3: (* Start Feeders with Tension Control *)
        feeder_running := TRUE;
        feeder1_active := TRUE;
        feeder2_active := TRUE;
        
        // Start timer for tension establishment
        feeder_timer(IN := TRUE);
        IF feeder_timer.Q THEN
            // Tension established after timer expires
            tension_established := TRUE;
            next_state := 4;
            feeder_timer(IN := FALSE);
        ELSE
            tension_established := FALSE;
            next_state := 3;
        END_IF;
        
    4: (* Start Cutters *)
        cutter_running := TRUE;
        horizontal_cutter_active := TRUE;
        vertical_cutter_active := TRUE;
        
        // Start timer for cutter activation
        cutter_timer(IN := TRUE);
        IF cutter_timer.Q THEN
            next_state := 5;
            cutter_timer(IN := FALSE);
        ELSE
            next_state := 4;
        END_IF;
        
    5: (* Machine Ready *)
        machine_ready := TRUE;
        startup_complete := TRUE;
        
        // Wait for stop command
        IF stop_machine THEN
            next_state := 6;
        ELSE
            next_state := 5;
        END_IF;
        
    6: (* Stop Cutters *)
        cutter_running := FALSE;
        horizontal_cutter_active := FALSE;
        vertical_cutter_active := FALSE;
        
        // Start timer for cutter deactivation
        cutter_timer(IN := TRUE);
        IF cutter_timer.Q THEN
            next_state := 7;
            cutter_timer(IN := FALSE);
        ELSE
            next_state := 6;
        END_IF;
        
    7: (* Stop Feeders *)
        feeder_running := FALSE;
        feeder1_active := FALSE;
        feeder2_active := FALSE;
        tension_established := FALSE;
        
        // Start timer for feeder shutdown
        feeder_timer(IN := TRUE);
        IF feeder_timer.Q THEN
            next_state := 8;
            feeder_timer(IN := FALSE);
        ELSE
            next_state := 7;
        END_IF;
        
    8: (* Stop Cooling Stations *)
        cooling_running := FALSE;
        
        // Deactivate all 8 cooling stations
        FOR i := 1 TO 8 DO
            cooling_stations_active[i] := FALSE;
        END_FOR;
        
        // Start timer for cooling shutdown
        cooling_timer(IN := TRUE);
        IF cooling_timer.Q THEN
            next_state := 9;
            cooling_timer(IN := FALSE);
        ELSE
            next_state := 8;
        END_IF;
        
    9: (* Stop Heating Stations *)
        heating_running := FALSE;
        
        // Deactivate all 8 heating stations
        FOR i := 1 TO 8 DO
            heating_stations_active[i] := FALSE;
        END_FOR;
        
        // Start timer for heating shutdown
        heating_timer(IN := TRUE);
        IF heating_timer.Q THEN
            next_state := 10;
            heating_timer(IN := FALSE);
        ELSE
            next_state := 9;
        END_IF;
        
    10: (* Shutdown Complete *)
        machine_ready := FALSE;
        shutdown_complete := TRUE;
        
        // Return to idle when stop signal is released
        IF NOT stop_machine THEN
            next_state := 0;
        ELSE
            next_state := 10;
        END_IF;
        
    ELSE
        // Safety fallback to idle state
        next_state := 0;
END_CASE;

// Update state for next scan cycle
current_state := next_state;

END_FUNCTION_BLOCK