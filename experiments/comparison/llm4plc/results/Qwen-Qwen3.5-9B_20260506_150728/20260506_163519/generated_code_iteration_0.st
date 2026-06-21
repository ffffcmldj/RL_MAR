START_ST
FUNCTION_BLOCK AutomaticDoorControl
VAR_INPUT
    ProximitySensor : BOOL;
    ElapsedTime : DINT; (* Represents milliseconds elapsed since last open event *)
END_VAR

VAR_OUTPUT
    DoorOpen : BOOL;
END_VAR

VAR
    CurrentState : INT; (* 0: CLOSED, 1: OPEN, 2: CLOSING *)
    DoorOpenDuration : DINT := 5000; (* 5 seconds in milliseconds *)
END_VAR

END_VAR

BEGIN
    (* State Machine Logic *)
    CASE CurrentState OF
        0: (* STATE 0: CLOSED_IDLE *)
            (* Door is closed, waiting for sensor activation *)
            IF ProximitySensor THEN
                CurrentState := 1; (* Transition to OPENING/OPEN_HOLDING *)
            END_IF;
            
        1: (* STATE 1: OPEN_HOLDING *)
            (* Door is open. Check if sensor is lost or time limit reached *)
            IF (NOT ProximitySensor) OR (ElapsedTime >= DoorOpenDuration) THEN
                CurrentState := 2; (* Transition to CLOSING *)
            END_IF;
            
        2: (* STATE 2: CLOSING *)
            (* Door is closing. Once decision to close is made, reset state to Closed for next cycle *)
            (* This prevents rapid re-triggering if sensor bounces during the closing phase *)
            CurrentState := 0; (* Transition back to CLOSED_READY for next scan cycle *)
    END_CASE;

    (* Determine Output based on Current State *)
    (* DoorOpen is TRUE only in State 1 *)
    DoorOpen := (CurrentState = 1);

END_FUNCTION_BLOCK
END_ST