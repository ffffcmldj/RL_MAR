plaintext
START_ST
FUNCTION_BLOCK AutomaticDoorControl
VAR_INPUT
    ProximitySensor : BOOL; (* Input from the proximity sensor indicating if an object is nearby *)
    ElapsedTime : DINT; (* Input representing the elapsed time since the door was last opened, in milliseconds *)
END_VAR

VAR_OUTPUT
    DoorOpen : BOOL; (* Output indicating whether the door is open (TRUE) or closed (FALSE) *)
END_VAR

VAR
    state : INT := 0; (* Current state of the system: 0 = DOOR_CLOSED, 1 = DOOR_OPEN *)
    prevState : INT := 0; (* Previous state of the system, used for debugging or tracking state changes *)
    DoorOpenDuration : DINT := 5000; (* Constant duration for which the door remains open, in milliseconds *)
END_VAR

(* State Machine Logic *)
IF state = 0 THEN (* STATE 0: DOOR_CLOSED *)
    DoorOpen := FALSE; (* Ensure the door is closed *)
    
    (* Transition to STATE 1 if the proximity sensor is activated *)
    IF ProximitySensor = TRUE THEN
        prevState := state; (* Store the current state as the previous state *)
        state := 1; (* Transition to STATE 1: DOOR_OPEN *)
    END_IF;

ELSIF state = 1 THEN (* STATE 1: DOOR_OPEN *)
    DoorOpen := TRUE; (* Ensure the door is open *)
    
    (* Transition to STATE 0 if the proximity sensor is inactive and the elapsed time exceeds the open duration *)
    IF (ProximitySensor = FALSE) AND (ElapsedTime >= DoorOpenDuration) THEN
        prevState := state; (* Store the current state as the previous state *)
        state := 0; (* Transition to STATE 0: DOOR_CLOSED *)
    END_IF;
END_IF;

END_FUNCTION_BLOCK
END_ST