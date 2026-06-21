START_ST
FUNCTION_BLOCK FB_RequestHandler
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

CASE state OF
    0:
        listen := TRUE;
        IF request THEN
            state := 1;
            listen := FALSE;
        END_IF;
    1:
        listen := FALSE;
        IF done THEN
            state := 0;
            listen := TRUE;
        END_IF;
    ELSE
        state := 0;
        listen := TRUE;
END_CASE;

END_FUNCTION_BLOCK
END_ST