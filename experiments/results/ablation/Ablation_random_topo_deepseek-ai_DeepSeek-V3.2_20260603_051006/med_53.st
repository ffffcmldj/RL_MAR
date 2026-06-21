FUNCTION_BLOCK PouchMachine
VAR_INPUT
    start_machine: BOOL;
    stop_machine: BOOL;
    EmergencyStop: BOOL;
    HeatingStationReady_1: BOOL;
    HeatingStationReady_2: BOOL;
    HeatingStationReady_3: BOOL;
    HeatingStationReady_4: BOOL;
    HeatingStationReady_5: BOOL;
    HeatingStationReady_6: BOOL;
    HeatingStationReady_7: BOOL;
    HeatingStationReady_8: BOOL;
    CoolingStationReady_1: BOOL;
    CoolingStationReady_2: BOOL;
    CoolingStationReady_3: BOOL;
    CoolingStationReady_4: BOOL;
    CoolingStationReady_5: BOOL;
    CoolingStationReady_6: BOOL;
    CoolingStationReady_7: BOOL;
    CoolingStationReady_8: BOOL;
    Feeder1_TensionOK: BOOL;
    Feeder2_TensionOK: BOOL;
    HorizontalCutterReady: BOOL;
    VerticalCutterReady: BOOL;
END_VAR

VAR_OUTPUT
    machine_ready: BOOL;
    feeder_running: BOOL;
    cutter_running: BOOL;
    heating_running: BOOL;
    cooling_running: BOOL;
    Feeder1_Start: BOOL;
    Feeder2_Start: BOOL;
    HeatingStationStart_1: BOOL;
    HeatingStationStart_2: BOOL;
    HeatingStationStart_3: BOOL;
    HeatingStationStart_4: BOOL;
    HeatingStationStart_5: BOOL;
    HeatingStationStart_6: BOOL;
    HeatingStationStart_7: BOOL;
    HeatingStationStart_8: BOOL;
    CoolingStationStart_1: BOOL;
    CoolingStationStart_2: BOOL;
    CoolingStationStart_3: BOOL;
    CoolingStationStart_4: BOOL;
    CoolingStationStart_5: BOOL;
    CoolingStationStart_6: BOOL;
    CoolingStationStart_7: BOOL;
    CoolingStationStart_8: BOOL;
    HorizontalCutterStart: BOOL;
    VerticalCutterStart: BOOL;
END_VAR

VAR
    startup_complete: BOOL := FALSE;
    shutdown_complete: BOOL := FALSE;
    machine_state: INT := 0;
    startup_timer: TON;
    shutdown_timer: TON;
    heating_stations_ready: BOOL;
    cooling_stations_ready: BOOL;
    tension_established: BOOL;
    cutter_horizontal_ready: BOOL;
    cutter_vertical_ready: BOOL;
    feeder1_ready: BOOL;
    feeder2_ready: BOOL;
    start_rising_edge: R_TRIG;
    stop_rising_edge: R_TRIG;
    emergency_rising_edge: R_TRIG;
    heating_ok_array: ARRAY[1..8] OF BOOL;
    cooling_ok_array: ARRAY[1..8] OF BOOL;
END_VAR

// Edge detection for control signals
start_rising_edge(CLK := start_machine);
stop_rising_edge(CLK := stop_machine);
emergency_rising_edge(CLK := EmergencyStop);

// Initialize status arrays
heating_ok_array[1] := HeatingStationReady_1;
heating_ok_array[2] := HeatingStationReady_2;
heating_ok_array[3] := HeatingStationReady_3;
heating_ok_array[4] := HeatingStationReady_4;
heating_ok_array[5] := HeatingStationReady_5;
heating_ok_array[6] := HeatingStationReady_6;
heating_ok_array[7] := HeatingStationReady_7;
heating_ok_array[8] := HeatingStationReady_8;

cooling_ok_array[1] := CoolingStationReady_1;
cooling_ok_array[2] := CoolingStationReady_2;
cooling_ok_array[3] := CoolingStationReady_3;
cooling_ok_array[4] := CoolingStationReady_4;
cooling_ok_array[5] := CoolingStationReady_5;
cooling_ok_array[6] := CoolingStationReady_6;
cooling_ok_array[7] := CoolingStationReady_7;
cooling_ok_array[8] := CoolingStationReady_8;

// Check all heating stations are ready
heating_stations_ready := heating_ok_array[1] AND heating_ok_array[2] AND 
                         heating_ok_array[3] AND heating_ok_array[4] AND 
                         heating_ok_array[5] AND heating_ok_array[6] AND 
                         heating_ok_array[7] AND heating_ok_array[8];

// Check all cooling stations are ready
cooling_stations_ready := cooling_ok_array[1] AND cooling_ok_array[2] AND 
                         cooling_ok_array[3] AND cooling_ok_array[4] AND 
                         cooling_ok_array[5] AND cooling_ok_array[6] AND 
                         cooling_ok_array[7] AND cooling_ok_array[8];

// Check tension established on both feeders
tension_established := Feeder1_TensionOK AND Feeder2_TensionOK;

// Check both cutters are ready
cutter_horizontal_ready := HorizontalCutterReady;
cutter_vertical_ready := VerticalCutterReady;

// Emergency stop handling - immediate shutdown to state 0
IF EmergencyStop OR emergency_rising_edge.Q THEN
    machine_state := 0;
    startup_timer(IN := FALSE);
    shutdown_timer(IN := FALSE);
END_IF

CASE machine_state OF
    0: // Idle/Stopped state
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        startup_complete := FALSE;
        shutdown_complete := TRUE;
        
        // Reset all output commands
        Feeder1_Start := FALSE;
        Feeder2_Start := FALSE;
        HorizontalCutterStart := FALSE;
        VerticalCutterStart := FALSE;
        
        HeatingStationStart_1 := FALSE;
        HeatingStationStart_2 := FALSE;
        HeatingStationStart_3 := FALSE;
        HeatingStationStart_4 := FALSE;
        HeatingStationStart_5 := FALSE;
        HeatingStationStart_6 := FALSE;
        HeatingStationStart_7 := FALSE;
        HeatingStationStart_8 := FALSE;
        
        CoolingStationStart_1 := FALSE;
        CoolingStationStart_2 := FALSE;
        CoolingStationStart_3 := FALSE;
        CoolingStationStart_4 := FALSE;
        CoolingStationStart_5 := FALSE;
        CoolingStationStart_6 := FALSE;
        CoolingStationStart_7 := FALSE;
        CoolingStationStart_8 := FALSE;
        
        IF start_rising_edge.Q AND NOT EmergencyStop THEN
            machine_state := 1;
            shutdown_complete := FALSE;
        END_IF;
        
    1: // Start heating stations
        heating_running := TRUE;
        
        // Start all heating stations
        HeatingStationStart_1 := TRUE;
        HeatingStationStart_2 := TRUE;
        HeatingStationStart_3 := TRUE;
        HeatingStationStart_4 := TRUE;
        HeatingStationStart_5 := TRUE;
        HeatingStationStart_6 := TRUE;
        HeatingStationStart_7 := TRUE;
        HeatingStationStart_8 := TRUE;
        
        startup_timer(IN := TRUE, PT := T#5S);
        IF startup_timer.Q AND heating_stations_ready THEN
            machine_state := 2;
            startup_timer(IN := FALSE);
        ELSIF startup_timer.Q AND NOT heating_stations_ready THEN
            // Timeout without all stations ready - go to error state
            machine_state := 99;
        END_IF;
        
    2: // Start cooling stations
        cooling_running := TRUE;
        
        // Start all cooling stations
        CoolingStationStart_1 := TRUE;
        CoolingStationStart_2 := TRUE;
        CoolingStationStart_3 := TRUE;
        CoolingStationStart_4 := TRUE;
        CoolingStationStart_5 := TRUE;
        CoolingStationStart_6 := TRUE;
        CoolingStationStart_7 := TRUE;
        CoolingStationStart_8 := TRUE;
        
        startup_timer(IN := TRUE, PT := T#5S);
        IF startup_timer.Q AND cooling_stations_ready THEN
            machine_state := 3;
            startup_timer(IN := FALSE);
        ELSIF startup_timer.Q AND NOT cooling_stations_ready THEN
            machine_state := 99;
        END_IF;
        
    3: // Start feeders and establish tension
        feeder_running := TRUE;
        Feeder1_Start := TRUE;
        Feeder2_Start := TRUE;
        
        startup_timer(IN := TRUE, PT := T#10S);
        IF startup_timer.Q AND tension_established THEN
            feeder1_ready := TRUE;
            feeder2_ready := TRUE;
            machine_state := 4;
            startup_timer(IN := FALSE);
        ELSIF startup_timer.Q AND NOT tension_established THEN
            machine_state := 99;
        END_IF;
        
    4: // Start cutters
        cutter_running := TRUE;
        HorizontalCutterStart := TRUE;
        VerticalCutterStart := TRUE;
        
        startup_timer(IN := TRUE, PT := T#3S);
        IF startup_timer.Q AND cutter_horizontal_ready AND cutter_vertical_ready THEN
            machine_state := 5;
            startup_timer(IN := FALSE);
        ELSIF startup_timer.Q AND NOT (cutter_horizontal_ready AND cutter_vertical_ready) THEN
            machine_state := 99;
        END_IF;
        
    5: // Machine ready state
        machine_ready := TRUE;
        startup_complete := TRUE;
        
        IF stop_rising_edge.Q OR EmergencyStop THEN
            machine_state := 10;
        END_IF;
        
    10: // Shutdown - stop cutters
        cutter_running := FALSE;
        HorizontalCutterStart := FALSE;
        VerticalCutterStart := FALSE;
        
        shutdown_timer(IN := TRUE, PT := T#3S);
        IF shutdown_timer.Q THEN
            machine_state := 11;
            shutdown_timer(IN := FALSE);
        END_IF;
        
    11: // Shutdown - stop feeders
        feeder_running := FALSE;
        Feeder1_Start := FALSE;
        Feeder2_Start := FALSE;
        
        shutdown_timer(IN := TRUE, PT := T#5S);
        IF shutdown_timer.Q THEN
            machine_state := 12;
            shutdown_timer(IN := FALSE);
        END_IF;
        
    12: // Shutdown - stop cooling stations
        cooling_running := FALSE;
        CoolingStationStart_1 := FALSE;
        CoolingStationStart_2 := FALSE;
        CoolingStationStart_3 := FALSE;
        CoolingStationStart_4 := FALSE;
        CoolingStationStart_5 := FALSE;
        CoolingStationStart_6 := FALSE;
        CoolingStationStart_7 := FALSE;
        CoolingStationStart_8 := FALSE;
        
        shutdown_timer(IN := TRUE, PT := T#5S);
        IF shutdown_timer.Q THEN
            machine_state := 13;
            shutdown_timer(IN := FALSE);
        END_IF;
        
    13: // Shutdown - stop heating stations
        heating_running := FALSE;
        HeatingStationStart_1 := FALSE;
        HeatingStationStart_2 := FALSE;
        HeatingStationStart_3 := FALSE;
        HeatingStationStart_4 := FALSE;
        HeatingStationStart_5 := FALSE;
        HeatingStationStart_6 := FALSE;
        HeatingStationStart_7 := FALSE;
        HeatingStationStart_8 := FALSE;
        
        shutdown_timer(IN := TRUE, PT := T#5S);
        IF shutdown_timer.Q THEN
            machine_state := 14;
            shutdown_timer(IN := FALSE);
        END_IF;
        
    14: // Shutdown complete
        machine_ready := FALSE;
        shutdown_complete := TRUE;
        
        IF start_rising_edge.Q AND NOT EmergencyStop THEN
            machine_state := 1;
        END_IF;
        
    99: // Error state
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        
        // Stop all outputs
        Feeder1_Start := FALSE;
        Feeder2_Start := FALSE;
        HorizontalCutterStart := FALSE;
        VerticalCutterStart := FALSE;
        
        HeatingStationStart_1 := FALSE;
        HeatingStationStart_2 := FALSE;
        HeatingStationStart_3 := FALSE;
        HeatingStationStart_4 := FALSE;
        HeatingStationStart_5 := FALSE;
        HeatingStationStart_6 := FALSE;
        HeatingStationStart_7 := FALSE;
        HeatingStationStart_8 := FALSE;
        
        CoolingStationStart_1 := FALSE;
        CoolingStationStart_2 := FALSE;
        CoolingStationStart_3 := FALSE;
        CoolingStationStart_4 := FALSE;
        CoolingStationStart_5 := FALSE;
        CoolingStationStart_6 := FALSE;
        CoolingStationStart_7 := FALSE;
        CoolingStationStart_8 := FALSE;
        
        // Manual reset required
        IF EmergencyStop THEN
            machine_state := 0;
        END_IF;
        
    ELSE
        machine_state := 0;
END_CASE;
END_FUNCTION_BLOCK