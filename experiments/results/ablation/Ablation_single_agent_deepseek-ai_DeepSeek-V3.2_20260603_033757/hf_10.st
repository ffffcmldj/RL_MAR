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
    currentWindowSize : INT := 0; (* Current number of valid data points in buffer *)
    triggerPrev : BOOL := FALSE; (* Previous trigger state for edge detection *)
END_VAR

(* Main execution logic *)
IF reset THEN
    (* Reset all internal states *)
    bufferIndex := 1;
    sum := 0.0;
    currentWindowSize := 0;
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
        
        (* Update sum - remove oldest value if window is full *)
        IF currentWindowSize < windowSize THEN
            (* Window not yet full, just add new value *)
            sum := sum + value;
            currentWindowSize := currentWindowSize + 1;
        ELSE
            (* Window is full, replace oldest value *)
            sum := sum - dataBuffer[bufferIndex] + value;
        END_IF;
        
        (* Update buffer index with wrap-around *)
        bufferIndex := bufferIndex + 1;
        IF bufferIndex > windowSize THEN
            bufferIndex := 1;
        END_IF;
        
        (* Calculate average *)
        IF currentWindowSize > 0 THEN
            average := sum / currentWindowSize;
        ELSE
            average := 0.0;
        END_IF;
        
        (* Update windowSizeReached flag *)
        windowSizeReached := (currentWindowSize >= windowSize);
        
        (* Clear error and set success status *)
        error := FALSE;
        status := 16#0000;
    END_IF;
    
    (* Update trigger previous state for edge detection *)
    triggerPrev := trigger;
END_IF;

(* Ensure outputs are valid even when no new data is processed *)
IF NOT (cyclicExecution OR (trigger AND NOT triggerPrev)) AND NOT reset THEN
    (* Maintain current outputs when not processing new data *)
    IF currentWindowSize > 0 THEN
        average := sum / currentWindowSize;
    ELSE
        average := 0.0;
    END_IF;
    windowSizeReached := (currentWindowSize >= windowSize);
END_IF;

END_FUNCTION_BLOCK