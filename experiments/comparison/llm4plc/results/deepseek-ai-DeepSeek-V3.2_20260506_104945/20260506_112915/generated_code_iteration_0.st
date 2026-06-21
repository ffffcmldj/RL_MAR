START_ST
FUNCTION_BLOCK AutomaticDoorControl
VAR_INPUT
    ProximitySensor : BOOL;
    ElapsedTime : DINT;
END_VAR

VAR_OUTPUT
    DoorOpen : BOOL;
END_VAR

VAR
    state : INT := 0;
    prevState : INT := 0;
    DoorOpenDuration : DINT := 5000;
END_VAR

(* Finite State Machine Implementation *)
prevState := state;

CASE state OF
    0: (* STATE 0: IDLE - Door closed, waiting for activation *)
        DoorOpen := FALSE;
        IF ProximitySensor THEN
            state := 1; (* Transition to OPENING *)
        END_IF;

    1: (* STATE 1: OPENING - Door begins opening *)
        DoorOpen := TRUE;
        state := 2; (* Immediate transition to OPEN *)

    2: (* STATE 2: OPEN - Door fully open, held by sensor or timing *)
        DoorOpen := TRUE;
        IF (NOT ProximitySensor) AND (ElapsedTime >= DoorOpenDuration) THEN
            state := 3; (* Transition to CLOSING *)
        END_IF;

    3: (* STATE 3: CLOSING - Door begins closing *)
        DoorOpen := FALSE;
        state := 0; (* Immediate transition to IDLE *)

    ELSE
        (* Fallback: Reset to IDLE state in case of invalid state *)
        state := 0;
        DoorOpen := FALSE;
END_CASE;

END_FUNCTION_BLOCK
END_ST