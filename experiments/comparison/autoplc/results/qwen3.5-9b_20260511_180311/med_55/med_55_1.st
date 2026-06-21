FUNCTION_BLOCK StateMachineControl
VAR_INPUT
    request : BOOL;
    done : BOOL;
END_VAR
VAR_OUTPUT
    listen : BOOL;
END_VAR
VAR
    state : INT := 0;
END_VAR

IF state = 0 AND request = TRUE THEN
    state := 1;
END_IF;

IF state = 1 AND done = TRUE THEN
    state := 0;
END_IF;

IF state = 0 THEN
    listen := TRUE;
ELSE
    listen := FALSE;
END_IF;

END_FUNCTION_BLOCK