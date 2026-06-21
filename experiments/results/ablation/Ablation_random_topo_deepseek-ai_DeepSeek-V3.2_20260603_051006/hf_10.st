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
    bufferIndex : INT;
    sum : REAL;
    elementCount : INT;
    prevTrigger : BOOL;
END_VAR

// Initialize variables
bufferIndex := 1;
sum := 0.0;
elementCount := 0;
prevTrigger := FALSE;
average := 0.0;
windowSizeReached := FALSE;
error := FALSE;
status := 16#0000;

// Check for reset condition
IF reset THEN
    bufferIndex := 1;
    sum := 0.0;
    elementCount := 0;
    average := 0.0;
    windowSizeReached := FALSE;
    error := FALSE;
    status := 16#0000;
    RETURN;
END_IF;

// Validate window size
IF (windowSize < 1) OR (windowSize > 100) THEN
    error := TRUE;
    status := 16#8200;
    average := 0.0;
    windowSizeReached := FALSE;
    RETURN;
END_IF;

// Check if we should process new data
IF cyclicExecution OR (trigger AND NOT prevTrigger) THEN
    // Store previous value that will be overwritten
    IF elementCount >= windowSize THEN
        sum := sum - dataBuffer[bufferIndex];
    END_IF;
    
    // Store new value and update sum
    dataBuffer[bufferIndex] := value;
    sum := sum + value;
    
    // Update element count
    IF elementCount < windowSize THEN
        elementCount := elementCount + 1;
    END_IF;
    
    // Update buffer index (circular buffer)
    bufferIndex := bufferIndex + 1;
    IF bufferIndex > windowSize THEN
        bufferIndex := 1;
    END_IF;
    
    // Calculate average
    IF elementCount > 0 THEN
        average := sum / elementCount;
    ELSE
        average := 0.0;
    END_IF;
    
    // Check if window size is reached
    windowSizeReached := (elementCount >= windowSize);
END_IF;

// Store current trigger state for edge detection
prevTrigger := trigger;

// Clear error if window size is valid
IF NOT ((windowSize < 1) OR (windowSize > 100)) THEN
    error := FALSE;
    status := 16#0000;
END_IF;

END_FUNCTION_BLOCK