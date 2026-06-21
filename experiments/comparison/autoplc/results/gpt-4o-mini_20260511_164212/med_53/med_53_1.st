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
    i: INT; // Loop variable for heating and cooling stations
END_VAR

// Initialization
machine_ready := FALSE;
feeder_running := FALSE;
cutter_running := FALSE;
heating_running := FALSE;
cooling_running := FALSE;

// Main control logic
IF start_machine AND NOT machine_ready THEN
    // Startup Sequence
    startup_complete := FALSE;
    
    // Activate heating stations
    FOR i := 1 TO 8 DO
        heating_running := TRUE; // Simulate activation of heating station
    END_FOR;

    // Activate cooling stations
    FOR i := 1 TO 8 DO
        cooling_running := TRUE; // Simulate activation of cooling station
    END_FOR;

    // Start feeders
    feeder_running := TRUE; // Simulate starting feeders

    // Activate cutters
    cutter_running := TRUE; // Simulate activation of horizontal and vertical cutters

    // Check if all components are activated
    IF heating_running AND cooling_running AND feeder_running AND cutter_running THEN
        startup_complete := TRUE;
        machine_ready := TRUE; // Set machine to ready state
    END_IF;

ELSIF stop_machine AND machine_ready THEN
    // Shutdown Sequence
    shutdown_complete := FALSE;

    // Stop cutters
    cutter_running := FALSE; // Simulate stopping cutters

    // Stop feeders
    feeder_running := FALSE; // Simulate stopping feeders

    // Deactivate heating stations
    FOR i := 1 TO 8 DO
        heating_running := FALSE; // Simulate deactivation of heating station
    END_FOR;

    // Deactivate cooling stations
    FOR i := 1 TO 8 DO
        cooling_running := FALSE; // Simulate deactivation of cooling station
    END_FOR;

    // Check if all components are deactivated
    IF NOT heating_running AND NOT cooling_running AND NOT feeder_running AND NOT cutter_running THEN
        shutdown_complete := TRUE;
        machine_ready := FALSE; // Set machine to not-ready state
    END_IF;

END_IF;

END_FUNCTION_BLOCK