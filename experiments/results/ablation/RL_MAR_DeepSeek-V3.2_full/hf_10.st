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
    sum : REAL := 0.0;
    elementCount : INT := 0;
    triggerPrev : BOOL := FALSE;
    i : INT;
END_VAR

IF reset THEN
    sum := 0.0;
    average := 0.0;
    elementCount := 0;
    bufferIndex := 1;
    windowSizeReached := FALSE;
    error := FALSE;
    status := 16#0000;
    
    FOR i := 1 TO 100 DO
        dataBuffer[i] := 0.0;
    END_FOR;
ELSE
    IF (windowSize < 1) OR (windowSize > 100) THEN
        error := TRUE;
        status := 16#8200;
        average := 0.0;
        windowSizeReached := FALSE;
    ELSE
        error := FALSE;
        status := 16#0000;
        
        IF cyclicExecution THEN
            sum := sum - dataBuffer[bufferIndex];
            dataBuffer[bufferIndex] := value;
            sum := sum + value;
            
            bufferIndex := bufferIndex + 1;
            IF bufferIndex > windowSize THEN
                bufferIndex := 1;
            END_IF;
            
            IF elementCount < windowSize THEN
                elementCount := elementCount + 1;
            END_IF;
        ELSE
            IF trigger AND NOT triggerPrev THEN
                sum := sum - dataBuffer[bufferIndex];
                dataBuffer[bufferIndex] := value;
                sum := sum + value;
                
                bufferIndex := bufferIndex + 1;
                IF bufferIndex > windowSize THEN
                    bufferIndex := 1;
                END_IF;
                
                IF elementCount < windowSize THEN
                    elementCount := elementCount + 1;
                END_IF;
            END_IF;
            triggerPrev := trigger;
        END_IF;
        
        IF elementCount >= windowSize THEN
            windowSizeReached := TRUE;
            average := sum / INT_TO_REAL(windowSize);
        ELSE
            windowSizeReached := FALSE;
            IF elementCount > 0 THEN
                average := sum / INT_TO_REAL(elementCount);
            ELSE
                average := 0.0;
            END_IF;
        END_IF;
    END_IF;
END_IF;
END_FUNCTION_BLOCK