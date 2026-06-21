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
    state: INT := 0;
END_VAR

CASE state OF
    0:
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        startup_complete := FALSE;
        shutdown_complete := FALSE;
        IF start_machine THEN
            state := 1;
        END_IF;
    1:
        heating_running := TRUE;
        state := 2;
    2:
        cooling_running := TRUE;
        state := 3;
    3:
        feeder_running := TRUE;
        state := 4;
    4:
        cutter_running := TRUE;
        state := 5;
    5:
        machine_ready := TRUE;
        startup_complete := TRUE;
        shutdown_complete := FALSE;
        IF stop_machine THEN
            state := 10;
        END_IF;
    10:
        cutter_running := FALSE;
        state := 11;
    11:
        feeder_running := FALSE;
        state := 12;
    12:
        cooling_running := FALSE;
        state := 13;
    13:
        heating_running := FALSE;
        state := 14;
    14:
        machine_ready := FALSE;
        startup_complete := FALSE;
        shutdown_complete := TRUE;
        state := 0;
    ELSE
        state := 0;
END_CASE;

END_FUNCTION_BLOCK;