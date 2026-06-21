

START_ST
FUNCTION_BLOCK RequestHandler
VAR_INPUT
    Enable : BOOL;
    TimeoutDuration : TIME;
END_VAR
VAR_OUTPUT
    IsTimeout : BOOL;
    Status : STRING;
END_VAR
VAR
    LocalTimeout : BOOL;
    CurrentTime : TIME;
END_VAR
BEGIN
    IF Enable THEN
        (* Simulate a timeout check *)
        LocalTimeout := TRUE; (* Placeholder for actual timing logic *)
        
        IF LocalTimeout THEN
            IsTimeout := TRUE;
            Status := 'RequestTimeout';
        ELSE
            IsTimeout := FALSE;
            Status := 'RequestActive';
        END_IF;
    ELSE
        IsTimeout := FALSE;
        Status := 'Disabled';
    END_IF;
END_FUNCTION_BLOCK
END_ST