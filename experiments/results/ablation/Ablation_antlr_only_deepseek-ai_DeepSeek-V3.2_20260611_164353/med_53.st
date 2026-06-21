TYPE E_MachineState :
(
    IDLE,
    START_HEATING,
    START_COOLING,
    START_FEEDERS,
    START_CUTTERS,
    MACHINE_READY,
    STOP_CUTTERS,
    STOP_FEEDERS,
    STOP_HEATING,
    STOP_COOLING,
    EMERGENCY_STOP
);
END_TYPE

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
    eCurrentState: E_MachineState := IDLE;
END_VAR

(* Main State Machine Logic *)
CASE eCurrentState OF
    IDLE:
        (* Reset all outputs and internal flags *)
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        startup_complete := FALSE;
        shutdown_complete := FALSE;

        (* Transition logic from IDLE state *)
        IF start_machine AND NOT stop_machine THEN
            eCurrentState := START_HEATING;
        END_IF;

    START_HEATING:
        (* Activate all 8 heating stations *)
        heating_running := TRUE;
        
        (* Transition logic *)
        IF stop_machine THEN
            eCurrentState := EMERGENCY_STOP;
        ELSIF heating_running THEN
            eCurrentState := START_COOLING;
        END_IF;

    START_COOLING:
        (* Activate all 8 cooling stations *)
        cooling_running := TRUE;
        
        (* Transition logic *)
        IF stop_machine THEN
            eCurrentState := EMERGENCY_STOP;
        ELSIF cooling_running AND heating_running THEN
            eCurrentState := START_FEEDERS;
        END_IF;

    START_FEEDERS:
        (* Start both feeder units and establish winding tension *)
        feeder_running := TRUE;
        
        (* Transition logic - wait for winding tension to be established *)
        IF stop_machine THEN
            eCurrentState := EMERGENCY_STOP;
        ELSIF feeder_running AND heating_running AND cooling_running THEN
            eCurrentState := START_CUTTERS;
        END_IF;

    START_CUTTERS:
        (* Activate both horizontal and vertical cutters *)
        cutter_running := TRUE;
        
        (* Transition logic *)
        IF stop_machine THEN
            eCurrentState := EMERGENCY_STOP;
        ELSIF cutter_running AND feeder_running AND heating_running AND cooling_running THEN
            eCurrentState := MACHINE_READY;
        END_IF;

    MACHINE_READY:
        (* Set machine to ready state *)
        machine_ready := TRUE;
        startup_complete := TRUE;
        shutdown_complete := FALSE;
        
        (* Transition logic *)
        IF stop_machine THEN
            eCurrentState := STOP_CUTTERS;
        END_IF;

    STOP_CUTTERS:
        (* Stop both horizontal and vertical cutters *)
        cutter_running := FALSE;
        machine_ready := FALSE;
        
        (* Transition logic - wait for cutters to fully stop *)
        IF NOT cutter_running AND NOT stop_machine THEN
            eCurrentState := STOP_FEEDERS;
        END_IF;

    STOP_FEEDERS:
        (* Stop both feeder units *)
        feeder_running := FALSE;
        
        (* Transition logic - ensure proper winding tension release *)
        IF NOT feeder_running AND NOT cutter_running AND NOT stop_machine THEN
            eCurrentState := STOP_HEATING;
        END_IF;

    STOP_HEATING:
        (* Deactivate all 8 heating stations *)
        heating_running := FALSE;
        
        (* Transition logic *)
        IF NOT heating_running AND NOT feeder_running AND NOT cutter_running AND NOT stop_machine THEN
            eCurrentState := STOP_COOLING;
        END_IF;

    STOP_COOLING:
        (* Deactivate all 8 cooling stations *)
        cooling_running := FALSE;
        
        (* Transition logic *)
        IF NOT cooling_running AND NOT heating_running AND NOT feeder_running AND NOT cutter_running THEN
            eCurrentState := IDLE;
        END_IF;

    EMERGENCY_STOP:
        (* Immediate shutdown of all components *)
        cutter_running := FALSE;
        feeder_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        machine_ready := FALSE;
        shutdown_complete := TRUE;
        startup_complete := FALSE;
        
        (* Transition logic - require stop to be released before returning to IDLE *)
        IF NOT stop_machine THEN
            eCurrentState := IDLE;
        END_IF;
END_CASE;

END_FUNCTION_BLOCK;