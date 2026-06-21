FUNCTION_BLOCK FloatingAverage
VAR_INPUT
    cyclicExecution : BOOL; (* When TRUE, periodic reading is performed, and trigger has no effect *)
    trigger : BOOL; (* External trigger signal, reads value upon each rising edge *)
    value : REAL; (* Newly read data value *)
    windowSize : INT; (* The window size for the moving average, which must be between 1 and 100 *)
    reset : BOOL; (* Reset signal, resets the moving average calculation when TRUE *)
END_VAR
VAR_OUTPUT
    average : REAL; (* The moving average *)
    windowSizeReached : BOOL; (* FALSE: Maximum window width not yet reached, TRUE: Maximum window width has been reached *)
    error : BOOL; (* FALSE: No error occurred, TRUE: An error occurred during the execution of FB *)
    status : WORD; (* Status code *)
END_VAR
VAR
    (* Data buffer and management *)
    dataBuffer : ARRAY[1..100] OF REAL; (* Circular buffer for data values *)
    bufferIndex : INT := 1; (* Current insertion index in the circular buffer *)
    sampleCount : INT := 0; (* Number of valid samples currently in the buffer *)
    sum : REAL := 0.0; (* Running sum of the valid samples in the buffer *)
    
    (* Edge detection and state tracking *)
    triggerPrev : BOOL := FALSE; (* Previous state of trigger for rising edge detection *)
    cyclicPrev : BOOL := FALSE; (* Previous state of cyclicExecution for edge detection *)
    
    (* Internal validated window size *)
    internalWindowSize : INT := 1;
END_VAR

(* ================================ *)
(* RESET LOGIC - Highest Priority   *)
(* ================================ *)
IF reset THEN
    (* Clear the data buffer *)
    FOR bufferIndex := 1 TO 100 DO
        dataBuffer[bufferIndex] := 0.0;
    END_FOR;
    
    (* Reset all internal state variables *)
    bufferIndex := 1;
    sampleCount := 0;
    sum := 0.0;
    triggerPrev := FALSE;
    cyclicPrev := FALSE;
    
    (* Reset outputs *)
    average := 0.0;
    windowSizeReached := FALSE;
    error := FALSE;
    status := 16#0000; (* Execution successful *)
    
    (* Validate and set internal window size after reset *)
    IF (windowSize >= 1) AND (windowSize <= 100) THEN
        internalWindowSize := windowSize;
    ELSE
        internalWindowSize := 1; (* Default to minimum valid size *)
    END_IF;
    
    RETURN; (* Exit function block after reset *)
END_IF;

(* ================================ *)
(* WINDOW SIZE VALIDATION           *)
(* ================================ *)
IF (windowSize < 1) OR (windowSize > 100) THEN
    error := TRUE;
    status := 16#8200; (* Window length setting error *)
    average := 0.0;
    windowSizeReached := FALSE;
    RETURN; (* Exit function block on error *)
ELSE
    error := FALSE;
    status := 16#0000; (* Execution successful *)
    internalWindowSize := windowSize;
END_IF;

(* ================================ *)
(* DATA ACQUISITION LOGIC           *)
(* ================================ *)
IF cyclicExecution THEN
    (* Cyclic mode: process every scan *)
    IF NOT cyclicPrev THEN
        cyclicPrev := TRUE; (* Set for next scan *)
        
        (* Store the old value that will be overwritten *)
        oldValue : REAL;
        IF sampleCount >= internalWindowSize THEN
            (* Buffer is full, calculate index of oldest value to be overwritten *)
            oldValue := dataBuffer[((bufferIndex - internalWindowSize - 1 + 100) MOD 100) + 1];
        ELSE
            oldValue := 0.0; (* No value to remove when buffer not full *)
        END_IF;
        
        (* Update buffer with new value *)
        dataBuffer[bufferIndex] := value;
        
        (* Update running sum *)
        sum := sum + value - oldValue;
        
        (* Update buffer index (circular) *)
        bufferIndex := (bufferIndex MOD 100) + 1;
        
        (* Update sample count (capped at window size) *)
        IF sampleCount < internalWindowSize THEN
            sampleCount := sampleCount + 1;
        END_IF;
    END_IF;
    
    (* Reset trigger edge detection in cyclic mode *)
    triggerPrev := FALSE;
ELSE
    (* Triggered mode: only process on rising edge of trigger *)
    cyclicPrev := FALSE; (* Reset cyclic edge detection *)
    
    IF trigger AND NOT triggerPrev THEN
        (* Rising edge detected *)
        triggerPrev := TRUE;
        
        (* Store the old value that will be overwritten *)
        oldValue : REAL;
        IF sampleCount >= internalWindowSize THEN
            (* Buffer is full, calculate index of oldest value to be overwritten *)
            oldValue := dataBuffer[((bufferIndex - internalWindowSize - 1 + 100) MOD 100) + 1];
        ELSE
            oldValue := 0.0; (* No value to remove when buffer not full *)
        END_IF;
        
        (* Update buffer with new value *)
        dataBuffer[bufferIndex] := value;
        
        (* Update running sum *)
        sum := sum + value - oldValue;
        
        (* Update buffer index (circular) *)
        bufferIndex := (bufferIndex MOD 100) + 1;
        
        (* Update sample count (capped at window size) *)
        IF sampleCount < internalWindowSize THEN
            sampleCount := sampleCount + 1;
        END_IF;
    ELSIF NOT trigger THEN
        (* Reset edge detection when trigger goes low *)
        triggerPrev := FALSE;
    END_IF;
END_IF;

(* ================================ *)
(* AVERAGE CALCULATION              *)
(* ================================ *)
IF sampleCount > 0 THEN
    (* Safe division - sampleCount is guaranteed > 0 *)
    average := sum / INT_TO_REAL(sampleCount);
    
    (* Update windowSizeReached flag *)
    windowSizeReached := (sampleCount >= internalWindowSize);
ELSE
    (* No samples yet *)
    average := 0.0;
    windowSizeReached := FALSE;
END_IF;

END_FUNCTION_BLOCK;