FUNCTION_BLOCK FloatingAverage
VAR_INPUT
    cyclicExecution : BOOL;
    trigger : BOOL;
    value : REAL;
    windowSize : INT;
    reset : BOOL;
END_VAR
VAR_OUTPUT
    average : REAL;
    windowSizeReached : BOOL;
    error : BOOL;
    status : WORD;
END_VAR
VAR
    dataBuffer : ARRAY[1..100] OF REAL;
    bufferIndex : INT := 1;
    sum : REAL := REAL(0.0);
    prevTrigger : BOOL;
    currentCount : INT;
END_VAR

IF reset = TRUE THEN
    bufferIndex := 1;
    sum := REAL(0.0);
    FOR i := 1 TO 100 DO
        dataBuffer[i] := REAL(0.0);
    END_FOR;
END_IF

IF windowSize < 1 OR windowSize > 100 THEN
    error := TRUE;
    status := 16#8200;
    average := 0.0;
    windowSizeReached := FALSE;
ELSE
    error := FALSE;
    status := 16#0000;
    
    IF cyclicExecution = TRUE OR (trigger = TRUE AND prevTrigger = FALSE) THEN
        IF bufferIndex > windowSize THEN
            bufferIndex := bufferIndex - 1;
        END_IF;
        
        dataBuffer[bufferIndex] := value;
        sum := sum + value;
        bufferIndex := bufferIndex + 1;
        
        IF bufferIndex > windowSize THEN
            windowSizeReached := TRUE;
        ELSE
            windowSizeReached := FALSE;
        END_IF;
    END_IF;
    
    IF windowSizeReached = TRUE THEN
        average := sum / REAL(windowSize);
    ELSE
        currentCount := bufferIndex - 1;
        IF currentCount > 0 THEN
            average := sum / REAL(currentCount);
        ELSE
            average := 0.0;
        END_IF;
    END_IF;
END_IF;

prevTrigger := trigger;

END_FUNCTION_BLOCK