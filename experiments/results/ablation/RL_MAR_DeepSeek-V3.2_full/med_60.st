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
                listen := FALSE;
                state := 1;
            END_IF;
        1:
            listen := FALSE;
            IF done THEN
                listen := TRUE;
                state := 0;
            END_IF;
    END_CASE;

END_FUNCTION_BLOCK;