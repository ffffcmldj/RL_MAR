FUNCTION_BLOCK PouchMachine
VAR_INPUT
    start_machine: BOOL;
    stop_machine: BOOL;
    emergency_stop: BOOL := TRUE; (* Safety input - normally TRUE *)
    tension_sensor1: BOOL; (* Tension feedback from feeder 1 *)
    tension_sensor2: BOOL; (* Tension feedback from feeder 2 *)
    cutter_home_pos: BOOL; (* Horizontal cutter at home position *)
    cutter_vert_home: BOOL; (* Vertical cutter at home position *)
END_VAR

VAR_OUTPUT
    machine_ready: BOOL;
    feeder_running: BOOL;
    cutter_running: BOOL;
    heating_running: BOOL;
    cooling_running: BOOL;
    startup_in_progress: BOOL;
    shutdown_in_progress: BOOL;
    fault_condition: BOOL;
    fault_code: INT;
END_VAR

VAR
    startup_complete: BOOL := FALSE;
    shutdown_complete: BOOL := TRUE;
    machine_state: INT := 0;
    step_timer: TON;
    heating_stations_active: ARRAY[1..8] OF BOOL;
    cooling_stations_active: ARRAY[1..8] OF BOOL;
    feeder1_tension_ok: BOOL;
    feeder2_tension_ok: BOOL;
    winding_tension_ok: BOOL;
    horizontal_cutter_ready: BOOL;
    vertical_cutter_ready: BOOL;
    startup_step: INT := 0;
    shutdown_step: INT := 0;
    i: INT;
END_VAR

(* Initialize timers *)
step_timer(IN := FALSE, PT := T#1S);

(* Main state machine *)
IF emergency_stop THEN
    CASE machine_state OF
        (* IDLE STATE *)
        0: (* Machine stopped, ready for startup *)
            machine_ready := FALSE;
            feeder_running := FALSE;
            cutter_running := FALSE;
            heating_running := FALSE;
            cooling_running := FALSE;
            startup_in_progress := FALSE;
            shutdown_in_progress := FALSE;
            fault_condition := FALSE;
            fault_code := 0;
            startup_complete := FALSE;
            shutdown_complete := TRUE;
            
            (* Reset all stations *)
            FOR i := 1 TO 8 DO
                heating_stations_active[i] := FALSE;
                cooling_stations_active[i] := FALSE;
            END_FOR;
            
            horizontal_cutter_ready := FALSE;
            vertical_cutter_ready := FALSE;
            feeder1_tension_ok := FALSE;
            feeder2_tension_ok := FALSE;
            winding_tension_ok := FALSE;
            
            IF start_machine AND NOT stop_machine THEN
                machine_state := 1; (* Start startup sequence *)
                startup_step := 1;
                step_timer(IN := TRUE, PT := T#1S);
            END_IF;
        
        (* STARTUP SEQUENCE *)
        1: (* Startup sequence active *)
            startup_in_progress := TRUE;
            shutdown_in_progress := FALSE;
            
            CASE startup_step OF
                1: (* Step 1: Activate heating stations *)
                    heating_running := TRUE;
                    FOR i := 1 TO 8 DO
                        heating_stations_active[i] := TRUE;
                    END_FOR;
                    
                    IF step_timer.Q THEN
                        step_timer(IN := FALSE, PT := T#1S);
                        startup_step := 2;
                        step_timer(IN := TRUE, PT := T#1S);
                    END_IF;
                    
                2: (* Step 2: Activate cooling stations *)
                    cooling_running := TRUE;
                    FOR i := 1 TO 8 DO
                        cooling_stations_active[i] := TRUE;
                    END_FOR;
                    
                    IF step_timer.Q THEN
                        step_timer(IN := FALSE, PT := T#1S);
                        startup_step := 3;
                        step_timer(IN := TRUE, PT := T#2S);
                    END_IF;
                    
                3: (* Step 3: Start feeders and establish tension *)
                    feeder_running := TRUE;
                    
                    (* Check tension from both feeders *)
                    feeder1_tension_ok := tension_sensor1;
                    feeder2_tension_ok := tension_sensor2;
                    winding_tension_ok := feeder1_tension_ok AND feeder2_tension_ok;
                    
                    IF step_timer.Q THEN
                        IF winding_tension_ok THEN
                            step_timer(IN := FALSE, PT := T#1S);
                            startup_step := 4;
                            step_timer(IN := TRUE, PT := T#1S);
                        ELSE
                            (* Tension not established - fault *)
                            machine_state := 99;
                            fault_condition := TRUE;
                            fault_code := 1; (* Tension fault *)
                        END_IF;
                    END_IF;
                    
                4: (* Step 4: Activate cutters *)
                    IF cutter_home_pos AND cutter_vert_home THEN
                        horizontal_cutter_ready := TRUE;
                        vertical_cutter_ready := TRUE;
                        cutter_running := TRUE;
                        
                        IF step_timer.Q THEN
                            step_timer(IN := FALSE, PT := T#1S);
                            startup_step := 5;
                            step_timer(IN := TRUE, PT := T#500MS);
                        END_IF;
                    ELSE
                        (* Cutters not in home position - fault *)
                        machine_state := 99;
                        fault_condition := TRUE;
                        fault_code := 2; (* Cutter position fault *)
                    END_IF;
                    
                5: (* Step 5: Set machine to ready state *)
                    IF step_timer.Q THEN
                        machine_ready := TRUE;
                        startup_complete := TRUE;
                        shutdown_complete := FALSE;
                        startup_in_progress := FALSE;
                        machine_state := 2; (* Running state *)
                        step_timer(IN := FALSE, PT := T#1S);
                    END_IF;
            END_CASE;
            
            (* Check for stop command during startup *)
            IF stop_machine THEN
                machine_state := 3; (* Go to shutdown *)
                shutdown_step := 1;
                step_timer(IN := TRUE, PT := T#1S);
            END_IF;
        
        (* RUNNING STATE *)
        2: (* Machine running normally *)
            (* Maintain station status *)
            heating_running := TRUE;
            cooling_running := TRUE;
            feeder_running := TRUE;
            cutter_running := TRUE;
            
            (* Continuously monitor tension *)
            feeder1_tension_ok := tension_sensor1;
            feeder2_tension_ok := tension_sensor2;
            winding_tension_ok := feeder1_tension_ok AND feeder2_tension_ok;
            
            IF NOT winding_tension_ok THEN
                machine_state := 99;
                fault_condition := TRUE;
                fault_code := 3; (* Running tension fault *)
            END_IF;
            
            (* Check for stop command *)
            IF stop_machine THEN
                machine_state := 3; (* Start shutdown sequence *)
                shutdown_step := 1;
                step_timer(IN := TRUE, PT := T#1S);
            END_IF;
        
        (* SHUTDOWN SEQUENCE *)
        3: (* Shutdown sequence active *)
            startup_in_progress := FALSE;
            shutdown_in_progress := TRUE;
            machine_ready := FALSE;
            
            CASE shutdown_step OF
                1: (* Step 1: Stop cutters *)
                    cutter_running := FALSE;
                    horizontal_cutter_ready := FALSE;
                    vertical_cutter_ready := FALSE;
                    
                    IF step_timer.Q THEN
                        step_timer(IN := FALSE, PT := T#1S);
                        shutdown_step := 2;
                        step_timer(IN := TRUE, PT := T#1S);
                    END_IF;
                    
                2: (* Step 2: Stop feeders *)
                    feeder_running := FALSE;
                    feeder1_tension_ok := FALSE;
                    feeder2_tension_ok := FALSE;
                    winding_tension_ok := FALSE;
                    
                    IF step_timer.Q THEN
                        step_timer(IN := FALSE, PT := T#1S);
                        shutdown_step := 3;
                        step_timer(IN := TRUE, PT := T#2S);
                    END_IF;
                    
                3: (* Step 3: Deactivate heating stations *)
                    heating_running := FALSE;
                    FOR i := 1 TO 8 DO
                        heating_stations_active[i] := FALSE;
                    END_FOR;
                    
                    IF step_timer.Q THEN
                        step_timer(IN := FALSE, PT := T#1S);
                        shutdown_step := 4;
                        step_timer(IN := TRUE, PT := T#2S);
                    END_IF;
                    
                4: (* Step 4: Deactivate cooling stations *)
                    cooling_running := FALSE;
                    FOR i := 1 TO 8 DO
                        cooling_stations_active[i] := FALSE;
                    END_FOR;
                    
                    IF step_timer.Q THEN
                        step_timer(IN := FALSE, PT := T#1S);
                        shutdown_step := 5;
                        step_timer(IN := TRUE, PT := T#500MS);
                    END_IF;
                    
                5: (* Step 5: Set machine to not-ready state *)
                    IF step_timer.Q THEN
                        startup_complete := FALSE;
                        shutdown_complete := TRUE;
                        shutdown_in_progress := FALSE;
                        machine_state := 0; (* Return to idle *)
                        step_timer(IN := FALSE, PT := T#1S);
                    END_IF;
            END_CASE;
            
            (* Check for start command during shutdown *)
            IF start_machine AND NOT stop_machine THEN
                (* Abort shutdown and restart *)
                machine_state := 1;
                startup_step := 1;
                step_timer(IN := TRUE, PT := T#1S);
            END_IF;
        
        (* FAULT STATE *)
        99: (* Fault condition *)
            machine_ready := FALSE;
            feeder_running := FALSE;
            cutter_running := FALSE;
            heating_running := FALSE;
            cooling_running := FALSE;
            startup_in_progress := FALSE;
            shutdown_in_progress := FALSE;
            
            (* Deactivate all stations *)
            FOR i := 1 TO 8 DO
                heating_stations_active[i] := FALSE;
                cooling_stations_active[i] := FALSE;
            END_FOR;
            
            (* Reset fault when emergency stop is cycled *)
            IF NOT emergency_stop THEN
                machine_state := 0;
                fault_condition := FALSE;
                fault_code := 0;
            END_IF;
            
    END_CASE;
ELSE
    (* Emergency stop active - force everything off *)
    machine_state := 0;
    machine_ready := FALSE;
    feeder_running := FALSE;
    cutter_running := FALSE;
    heating_running := FALSE;
    cooling_running := FALSE;
    startup_in_progress := FALSE;
    shutdown_in_progress := FALSE;
    fault_condition := FALSE;
    fault_code := 0;
    
    FOR i := 1 TO 8 DO
        heating_stations_active[i] := FALSE;
        cooling_stations_active[i] := FALSE;
    END_FOR;
    
    startup_complete := FALSE;
    shutdown_complete := TRUE;
    step_timer(IN := FALSE, PT := T#1S);
END_IF;
END_FUNCTION_BLOCK