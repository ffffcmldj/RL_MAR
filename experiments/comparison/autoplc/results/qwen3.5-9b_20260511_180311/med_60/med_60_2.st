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

    listen := FALSE;

    IF state = 0 THEN
        IF request = FALSE THEN
            listen := TRUE;
        ELSE
            listen := FALSE;
            done := FALSE;
            state := 1;
        END_IF;
    END_IF;

    IF state = 1 THEN
        IF done = TRUE THEN
            state := 0;
            listen := TRUE;
        END_IF;
    END_IF;

END_FUNCTION_BLOCK