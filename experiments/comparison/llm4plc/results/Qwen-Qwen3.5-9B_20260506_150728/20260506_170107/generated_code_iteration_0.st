START_ST
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
    current_state: INT;
    prev_state: INT;
    
    station_heating_ready: ARRAY[0..7] OF BOOL;
    station_cooling_ready: ARRAY[0..7] OF BOOL;
    tension_stable: BOOL;
    cutter_h_stopped: BOOL;
    cutter_v_stopped: BOOL;
    feeder_1_stopped: BOOL;
    feeder_2_stopped: BOOL;
    
    ctrl_heating: BOOL;
    ctrl_cooling: BOOL;
    ctrl_feeders: BOOL;
    ctrl_cutters: BOOL;
END_VAR

END_VAR

BEGIN
    (* STATE 0: IDLE *)
    IF current_state = 0 THEN
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        
        (* Transition to STATE 1 *)
        IF start_machine = TRUE AND stop_machine = FALSE THEN
            current_state := 1;
        END_IF;
    END_IF;

    (* STATE 1: INITIATE_STARTUP *)
    IF current_state = 1 THEN
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        
        (* Check if all heating and cooling stations are ready to proceed to warmup *)
        IF start_machine = TRUE AND stop_machine = FALSE THEN
            heating_running := TRUE;
            cooling_running := TRUE;
            ctrl_heating := TRUE;
            ctrl_cooling := TRUE;
            ctrl_feeders := FALSE;
            ctrl_cutters := FALSE;
            
            (* Check if all stations report ready to move to STATE 2 (Warmup Active) *)
            (* Note: Logic assumes 'ready' implies active heating/cooling cycle start *)
            IF (station_heating_ready[0] AND station_heating_ready[1] AND station_heating_ready[2] AND station_heating_ready[3] AND
                station_heating_ready[4] AND station_heating_ready[5] AND station_heating_ready[6] AND station_heating_ready[7]) AND
               (station_cooling_ready[0] AND station_cooling_ready[1] AND station_cooling_ready[2] AND station_cooling_ready[3] AND
                station_cooling_ready[4] AND station_cooling_ready[5] AND station_cooling_ready[6] AND station_cooling_ready[7]) THEN
                current_state := 2;
            END_IF;
        END_IF;
    END_IF;

    (* STATE 2: WARMUP_STATIONS *)
    IF current_state = 2 THEN
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := TRUE;
        cooling_running := TRUE;
        
        (* Logic: Wait until all stations report "Ready/Active" to move to STATE 3 *)
        (* In this context, we assume the 'ready' flag indicates the warmup cycle is complete and stable *)
        IF start_machine = TRUE AND stop_machine = FALSE THEN
            IF (station_heating_ready[0] AND station_heating_ready[1] AND station_heating_ready[2] AND station_heating_ready[3] AND
                station_heating_ready[4] AND station_heating_ready[5] AND station_heating_ready[6] AND station_heating_ready[7]) AND
               (station_cooling_ready[0] AND station_cooling_ready[1] AND station_cooling_ready[2] AND station_cooling_ready[3] AND
                station_cooling_ready[4] AND station_cooling_ready[5] AND station_cooling_ready[6] AND station_cooling_ready[7]) THEN
                current_state := 3;
            END_IF;
        END_IF;
    END_IF;

    (* STATE 3: TENSION_ESTABLISHMENT *)
    IF current_state = 3 THEN
        machine_ready := FALSE;
        feeder_running := TRUE;
        cutter_running := FALSE;
        heating_running := TRUE;
        cooling_running := TRUE;
        
        ctrl_heating := TRUE;
        ctrl_cooling := TRUE;
        ctrl_feeders := TRUE;
        ctrl_cutters := FALSE;
        
        (* Logic: Monitor tension sensor. Once tension is stable, move to STATE 4 *)
        IF start_machine = TRUE AND stop_machine = FALSE AND tension_stable = TRUE THEN
            current_state := 4;
        END_IF;
    END_IF;

    (* STATE 4: OPERATIONAL_READY *)
    IF current_state = 4 THEN
        machine_ready := TRUE;
        feeder_running := TRUE;
        cutter_running := FALSE;
        heating_running := TRUE;
        cooling_running := TRUE;
        
        ctrl_heating := TRUE;
        ctrl_cooling := TRUE;
        ctrl_feeders := TRUE;
        ctrl_cutters := FALSE;
        
        (* Logic: Wait for stop_machine signal to move to STATE 5 *)
        IF stop_machine = TRUE THEN
            current_state := 5;
        END_IF;
    END_IF;

    (* STATE 5: INITIATE_SHUTDOWN *)
    IF current_state = 5 THEN
        machine_ready := FALSE;
        feeder_running := TRUE;
        cutter_running := FALSE;
        heating_running := TRUE;
        cooling_running := TRUE;
        
        ctrl_heating := TRUE;
        ctrl_cooling := TRUE;
        ctrl_feeders := TRUE;
        ctrl_cutters := FALSE;
        
        (* Logic: Immediately stop cutters to move to STATE 6 *)
        ctrl_cutters := FALSE;
        current_state := 6;
    END_IF;

    (* STATE 6: CUTTER_STOP *)
    IF current_state = 6 THEN
        machine_ready := FALSE;
        feeder_running := TRUE;
        cutter_running := FALSE;
        heating_running := TRUE;
        cooling_running := TRUE;
        
        ctrl_heating := TRUE;
        ctrl_cooling := TRUE;
        ctrl_feeders := TRUE;
        ctrl_cutters := FALSE;
        
        (* Logic: Wait until both cutters report "Stopped" to move to STATE 7 *)
        IF stop_machine = TRUE AND cutter_h_stopped = TRUE AND cutter_v_stopped = TRUE THEN
            current_state := 7;
        END_IF;
    END_IF;

    (* STATE 7: FEEDER_STOP *)
    IF current_state = 7 THEN
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := TRUE;
        cooling_running := TRUE;
        
        ctrl_heating := TRUE;
        ctrl_cooling := TRUE;
        ctrl_feeders := FALSE;
        ctrl_cutters := FALSE;
        
        (* Logic: Wait until both feeders report "Stopped" to move to STATE 8 *)
        IF stop_machine = TRUE AND feeder_1_stopped = TRUE AND feeder_2_stopped = TRUE THEN
            current_state := 8;
        END_IF;
    END_IF;

    (* STATE 8: STATION_COOLDOWN *)
    IF current_state = 8 THEN
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        
        ctrl_heating := FALSE;
        ctrl_cooling := FALSE;
        ctrl_feeders := FALSE;
        ctrl_cutters := FALSE;
        
        (* Logic: Wait until all heating/cooling stations report "Off/Inactive" to move to STATE 9 *)
        IF stop_machine = TRUE AND 
           (station_heating_ready[0] = FALSE AND station_heating_ready[1] = FALSE AND station_heating_ready[2] = FALSE AND station_heating_ready[3] = FALSE AND
            station_heating_ready[4] = FALSE AND station_heating_ready[5] = FALSE AND station_heating_ready[6] = FALSE AND station_heating_ready[7] = FALSE) AND
           (station_cooling_ready[0] = FALSE AND station_cooling_ready[1] = FALSE AND station_cooling_ready[2] = FALSE AND station_cooling_ready[3] = FALSE AND
            station_cooling_ready[4] = FALSE AND station_cooling_ready[5] = FALSE AND station_cooling_ready[6] = FALSE AND station_cooling_ready[7] = FALSE) THEN
            current_state := 9;
        END_IF;
    END_IF;

    (* STATE 9: IDLE_RETURN *)
    IF current_state = 9 THEN
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        
        ctrl_heating := FALSE;
        ctrl_cooling := FALSE;
        ctrl_feeders := FALSE;
        ctrl_cutters := FALSE;
        
        (* Logic: Remain here until start_machine is pressed again *)
        IF start_machine = TRUE THEN
            current_state := 1;
        END_IF;
    END_IF;

END_FUNCTION_BLOCK
END_ST