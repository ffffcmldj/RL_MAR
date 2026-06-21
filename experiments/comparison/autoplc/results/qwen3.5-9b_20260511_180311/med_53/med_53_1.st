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
    startup_phase: INT;
    shutdown_phase: INT;
    startup_complete: BOOL := FALSE;
    shutdown_complete: BOOL := FALSE;
    temp_start: BOOL;
    temp_stop: BOOL;
END_VAR

current_state := 0;
startup_phase := 0;
shutdown_phase := 0;

IF start_machine THEN
    temp_start := TRUE;
ELSE
    temp_start := FALSE;
END_IF;

IF stop_machine THEN
    temp_stop := TRUE;
ELSE
    temp_stop := FALSE;
END_IF;

IF current_state = 0 THEN
    IF temp_start = TRUE AND temp_stop = FALSE THEN
        current_state := 1;
        startup_phase := 0;
        shutdown_phase := 0;
        startup_complete := FALSE;
        shutdown_complete := FALSE;
    END_IF;
END_IF;

IF current_state = 1 THEN
    IF temp_stop = TRUE THEN
        current_state := 0;
        startup_complete := FALSE;
        shutdown_complete := FALSE;
    ELSIF startup_phase = 0 THEN
        feeder_running := TRUE;
        cutter_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        startup_phase := 1;
    ELSIF startup_phase = 1 THEN
        feeder_running := TRUE;
        cutter_running := FALSE;
        heating_running := TRUE;
        cooling_running := TRUE;
        startup_phase := 2;
    ELSIF startup_phase = 2 THEN
        feeder_running := TRUE;
        cutter_running := TRUE;
        heating_running := TRUE;
        cooling_running := TRUE;
        startup_phase := 3;
    ELSIF startup_phase = 3 THEN
        feeder_running := TRUE;
        cutter_running := TRUE;
        heating_running := TRUE;
        cooling_running := TRUE;
        startup_complete := TRUE;
        current_state := 2;
    END_IF;
END_IF;

IF current_state = 2 THEN
    IF temp_stop = TRUE THEN
        current_state := 3;
        shutdown_phase := 0;
        startup_complete := FALSE;
        shutdown_complete := FALSE;
    ELSIF temp_start = TRUE THEN
        current_state := 1;
        startup_phase := 0;
        shutdown_phase := 0;
        startup_complete := FALSE;
        shutdown_complete := FALSE;
    END_IF;
END_IF;

IF current_state = 3 THEN
    IF temp_start = TRUE THEN
        current_state := 1;
        startup_phase := 0;
        shutdown_phase := 0;
        startup_complete := FALSE;
        shutdown_complete := FALSE;
    ELSIF shutdown_phase = 0 THEN
        cutter_running := FALSE;
        feeder_running := TRUE;
        heating_running := TRUE;
        cooling_running := TRUE;
        shutdown_phase := 1;
    ELSIF shutdown_phase = 1 THEN
        cutter_running := FALSE;
        feeder_running := FALSE;
        heating_running := TRUE;
        cooling_running := TRUE;
        shutdown_phase := 2;
    ELSIF shutdown_phase = 2 THEN
        cutter_running := FALSE;
        feeder_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        shutdown_complete := TRUE;
        current_state := 0;
    END_IF;
END_IF;

machine_ready := (current_state = 2);