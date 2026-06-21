plaintext
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
    state: INT := 0; // Current state of the machine
    heating_station_status: ARRAY[1..8] OF BOOL := [FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE]; // Status of each heating station
    cooling_station_status: ARRAY[1..8] OF BOOL := [FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE]; // Status of each cooling station
    feeders_running: BOOL := FALSE; // Indicates if feeders are running
    winding_tension_ok: BOOL := FALSE; // Indicates if winding tension is established
    cutters_activated: BOOL := FALSE; // Indicates if cutters are activated
    heating_complete: BOOL := FALSE; // Indicates if all heating stations are activated
    cooling_complete: BOOL := FALSE; // Indicates if all cooling stations are activated
    feeders_complete: BOOL := FALSE; // Indicates if feeders are running and tension is established
    cutters_complete: BOOL := FALSE; // Indicates if cutters are activated
    shutdown_complete: BOOL := FALSE; // Indicates if shutdown sequence is complete
END_VAR

// Main logic
IF start_machine AND NOT stop_machine THEN
    CASE state OF
        0: // IDLE
            // Reset all outputs
            machine_ready := FALSE;
            feeder_running := FALSE;
            cutter_running := FALSE;
            heating_running := FALSE;
            cooling_running := FALSE;

            // Transition to STARTUP_HEATING
            state := 1;

        1: // STARTUP_HEATING
            heating_running := TRUE;
            // Sequentially activate heating stations
            FOR i := 1 TO 8 DO
                heating_station_status[i] := TRUE;
            END_FOR;
            heating_complete := TRUE;

            // Transition to STARTUP_COOLING if heating is complete
            IF heating_complete THEN
                state := 2;
            END_IF;

        2: // STARTUP_COOLING
            cooling_running := TRUE;
            // Sequentially activate cooling stations
            FOR i := 1 TO 8 DO
                cooling_station_status[i] := TRUE;
            END_FOR;
            cooling_complete := TRUE;

            // Transition to STARTUP_FEEDERS if cooling is complete
            IF cooling_complete THEN
                state := 3;
            END_IF;

        3: // STARTUP_FEEDERS
            feeder_running := TRUE;
            feeders_running := TRUE;
            winding_tension_ok := TRUE;
            feeders_complete := feeders_running AND winding_tension_ok;

            // Transition to STARTUP_CUTTERS if feeders are complete
            IF feeders_complete THEN
                state := 4;
            END_IF;

        4: // STARTUP_CUTTERS
            cutter_running := TRUE;
            cutters_activated := TRUE;
            cutters_complete := cutters_activated;

            // Transition to MACHINE_READY if cutters are complete
            IF cutters_complete THEN
                state := 5;
            END_IF;

        5: // MACHINE_READY
            machine_ready := TRUE;

            // Stay in this state until stop_machine is TRUE
            IF stop_machine THEN
                state := 6;
            END_IF;

        6: // SHUTDOWN_CUTTERS
            cutter_running := FALSE;
            cutters_activated := FALSE;

            // Transition to SHUTDOWN_FEEDERS if cutters are deactivated
            IF NOT cutters_activated THEN
                state := 7;
            END_IF;

        7: // SHUTDOWN_FEEDERS
            feeder_running := FALSE;
            feeders_running := FALSE;
            winding_tension_ok := FALSE;

            // Transition to SHUTDOWN_COOLING if feeders are stopped
            IF NOT feeders_running THEN
                state := 8;
            END_IF;

        8: // SHUTDOWN_COOLING
            cooling_running := FALSE;
            // Sequentially deactivate cooling stations
            FOR i := 1 TO 8 DO
                cooling_station_status[i] := FALSE;
            END_FOR;

            // Transition to SHUTDOWN_HEATING if cooling stations are deactivated
            IF NOT cooling_running THEN
                state := 9;
            END_IF;

        9: // SHUTDOWN_HEATING
            heating_running := FALSE;
            // Sequentially deactivate heating stations
            FOR i := 1 TO 8 DO
                heating_station_status[i] := FALSE;
            END_FOR;

            // Transition to NOT_READY if heating stations are deactivated
            IF NOT heating_running THEN
                state := 10;
            END_IF;

        10: // NOT_READY
            machine_ready := FALSE;

            // Transition to IDLE if stop_machine is FALSE
            IF NOT stop_machine THEN
                state := 0;
            END_IF;

    END_CASE;
END_IF;
END_FUNCTION_BLOCK
END_ST