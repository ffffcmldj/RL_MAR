FUNCTION_BLOCK AutomaticDoorControl
VAR_INPUT
    ProximitySensor : BOOL;
    ElapsedTime : DINT; (* Changed from TIME to DINT, representing milliseconds *)
END_VAR

VAR_OUTPUT
    DoorOpen : BOOL;
END_VAR

VAR
    DoorOpenDuration : DINT := 5000; (* 5 seconds in milliseconds *)
    bDoorState : BOOL; (* Internal state: TRUE = Open, FALSE = Closed *)
END_VAR

(* Main control logic *)
IF NOT bDoorState THEN
    (* Door is currently closed *)
    IF ProximitySensor THEN
        (* Proximity sensor activated, open the door *)
        bDoorState := TRUE;
        DoorOpen := TRUE;
    ELSE
        (* Door remains closed *)
        DoorOpen := FALSE;
    END_IF;
ELSE
    (* Door is currently open *)
    IF NOT ProximitySensor OR (ElapsedTime >= DoorOpenDuration) THEN
        (* Either sensor is inactive OR open duration has elapsed, close the door *)
        bDoorState := FALSE;
        DoorOpen := FALSE;
    ELSE
        (* Keep door open *)
        DoorOpen := TRUE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK