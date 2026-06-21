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
    dataBuffer : ARRAY[1..100] OF REAL; (* Buffer to store the data values *)
    bufferIndex : INT := 1; (* Index to track the current position in the buffer *)
    sum : REAL := 0.0; (* Sum of the data values in the buffer *)
    count : INT := 0; (* Number of valid data points in buffer *)
    triggerPrev : BOOL := FALSE; (* Previous trigger state for edge detection *)
END_VAR

(* Main execution logic *)
IF reset THEN
    (* Reset all internal variables *)
    bufferIndex := 1;
    sum := 0.0;
    count := 0;
    average := 0.0;
    windowSizeReached := FALSE;
    error := FALSE;
    status := 16#0000;
    
    (* Clear buffer *)
    FOR i := 1 TO 100 DO
        dataBuffer[i] := 0.0;
    END_FOR;
    
ELSIF windowSize < 1 OR windowSize > 100 THEN
    (* Window size error *)
    error := TRUE;
    status := 16#8200;
    windowSizeReached := FALSE;
    
ELSE
    (* Check if we should process new data *)
    IF cyclicExecution OR (trigger AND NOT triggerPrev) THEN
        (* Update buffer with new value *)
        dataBuffer[bufferIndex] := value;
        
        (* Update sum - subtract old value if buffer is full *)
        IF count < windowSize THEN
            sum := sum + value;
            count := count + 1;
        ELSE
            (* Calculate index of oldest value to be replaced *)
            VAR
                oldestIndex : INT;
            END_VAR
            
            oldestIndex := bufferIndex - windowSize + 1;
            IF oldestIndex < 1 THEN
                oldestIndex := oldestIndex + 100;
            END_IF;
            
            sum := sum - dataBuffer[oldestIndex] + value;
        END_IF;
        
        (* Update buffer index with circular buffer logic *)
        bufferIndex := bufferIndex + 1;
        IF bufferIndex > 100 THEN
            bufferIndex := 1;
        END_IF;
        
        (* Calculate average *)
        IF count > 0 THEN
            average := sum / count;
        ELSE
            average := 0.0;
        END_IF;
        
        (* Check if window size is reached *)
        windowSizeReached := (count >= windowSize);
        
        (* Clear error if window size is valid *)
        error := FALSE;
        status := 16#0000;
    END_IF;
    
    (* Update trigger previous state for edge detection *)
    triggerPrev := trigger;
END_IF;

END_FUNCTION_BLOCK