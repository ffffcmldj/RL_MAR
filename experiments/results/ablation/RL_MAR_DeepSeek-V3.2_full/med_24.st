FUNCTION_BLOCK AutomaticDoorControl
VAR_INPUT
    ProximitySensor : BOOL;
    ElapsedTime : DINT;
END_VAR

VAR_OUTPUT
    DoorOpen : BOOL;
END_VAR

VAR
    DoorOpenDuration : DINT := 5000;
    CurrentState : INT := 0;
    NextState : INT := 0;
END_VAR

CASE CurrentState OF
    0:
        DoorOpen := FALSE;
        IF ProximitySensor THEN
            NextState := 1;
        ELSE
            NextState := 0;
        END_IF;
    1:
        DoorOpen := TRUE;
        NextState := 2;
    2:
        DoorOpen := TRUE;
        IF (NOT ProximitySensor) OR (ElapsedTime >= DoorOpenDuration) THEN
            NextState := 0;
        ELSE
            NextState := 2;
        END_IF;
    ELSE
        NextState := 0;
END_CASE;

CurrentState := NextState;

END_FUNCTION_BLOCK;