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
        heating_stations_active: INT := 0;
        cooling_stations_active: INT := 0;
        feeders_active: BOOL := FALSE;
        cutters_active: BOOL := FALSE;
    END_VAR

    // Start-Up Sequence
    IF start_machine AND NOT startup_complete THEN
        // Activate heating stations sequentially
        IF heating_stations_active < 8 THEN
            heating_stations_active := heating_stations_active + 1;
        ELSE
            heating_running := TRUE;
        END_IF

        // Activate cooling stations sequentially
        IF heating_running AND cooling_stations_active < 8 THEN
            cooling_stations_active := cooling_stations_active + 1;
        ELSE
            cooling_running := TRUE;
        END_IF

        // Start feeders and establish winding tension
        IF cooling_running AND NOT feeders_active THEN
            feeders_active := TRUE;
            feeder_running := TRUE;
        END_IF

        // Activate cutters
        IF feeder_running AND NOT cutters_active THEN
            cutters_active := TRUE;
            cutter_running := TRUE;
        END_IF

        // Set machine to ready state
        IF cutter_running THEN
            machine_ready := TRUE;
            startup_complete := TRUE;
        END_IF
    END_IF

    // Shutdown Sequence
    IF stop_machine AND NOT shutdown_complete THEN
        // Deactivate cutters
        IF cutters_active THEN
            cutters_active := FALSE;
            cutter_running := FALSE;
        END_IF

        // Stop feeders and release winding tension
        IF NOT cutters_active AND feeders_active THEN
            feeders_active := FALSE;
            feeder_running := FALSE;
        END_IF

        // Deactivate cooling stations sequentially
        IF NOT feeders_active AND cooling_stations_active > 0 THEN
            cooling_stations_active := cooling_stations_active - 1;
        ELSE
            cooling_running := FALSE;
        END_IF

        // Deactivate heating stations sequentially
        IF NOT cooling_running AND heating_stations_active > 0 THEN
            heating_stations_active := heating_stations_active - 1;
        ELSE
            heating_running := FALSE;
        END_IF

        // Set machine to not-ready state
        IF NOT heating_running THEN
            machine_ready := FALSE;
            shutdown_complete := TRUE;
        END_IF
    END_IF

    // Reset flags for next operation cycle
    IF NOT start_machine AND NOT stop_machine THEN
        startup_complete := FALSE;
        shutdown_complete := FALSE;
    END_IF
END_FUNCTION_BLOCK