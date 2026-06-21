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
    CurrentState : DINT;
    i : DINT;
END_VAR

CurrentState := 0;

IF ProximitySensor = TRUE AND DoorOpen = FALSE THEN
    CurrentState := 1;
    DoorOpen := TRUE;
ELSIF ProximitySensor = FALSE AND DoorOpen = TRUE THEN
    CurrentState := 2;
    DoorOpen := FALSE;
ELSIF DoorOpen = TRUE AND ElapsedTime >= DoorOpenDuration THEN
    CurrentState := 3;
    DoorOpen := FALSE;
ELSE
    CurrentState := 0;
    IF DoorOpen = FALSE THEN
        DoorOpen := FALSE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK