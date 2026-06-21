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
    prevTrigger : BOOL := FALSE;
    i : INT;
END_VAR

// Handle reset condition
IF reset THEN
    // Clear data buffer
    FOR i := 1 TO 100 DO
        dataBuffer[i] := 0.0;
    END_FOR;
    
    // Reset internal variables
    bufferIndex := 1;
    sum := 0.0;
    
    // Reset outputs
    average := 0.0;
    windowSizeReached := FALSE;
    error := FALSE;
    status := 16#0000;
    
    // Skip further processing in this cycle after reset
    RETURN;
END_IF;

// Validate windowSize
IF (windowSize < 1) OR (windowSize > 100) THEN
    error := TRUE;
    status := 16#8200;
    // Maintain current outputs when error occurs
    RETURN;
ELSE
    error := FALSE;
    status := 16#0000;
END_IF;

// Determine if new data should be processed
IF cyclicExecution THEN
    // Process new data every cycle
    // Continue with calculation
ELSIF trigger AND NOT prevTrigger THEN
    // Process new data on rising edge of trigger
    // Continue with calculation
ELSE
    // No new data to process, maintain current state
    prevTrigger := trigger;
    RETURN;
END_IF;

// Store previous trigger state for edge detection
prevTrigger := trigger;

// Store new value in buffer
dataBuffer[bufferIndex] := value;

// Update sum based on whether window is full
IF windowSizeReached THEN
    // Buffer is full, replace oldest value
    // Calculate index of oldest value (next position will be overwritten)
    IF bufferIndex = 1 THEN
        sum := sum - dataBuffer[windowSize] + value;
    ELSE
        sum := sum - dataBuffer[bufferIndex - 1] + value;
    END_IF;
ELSE
    // Buffer is not full yet, just add new value
    sum := sum + value;
END_IF;

// Update buffer index
bufferIndex := bufferIndex + 1;

// Check if window size has been reached
IF bufferIndex > windowSize THEN
    bufferIndex := 1;
    windowSizeReached := TRUE;
END_IF;

// Calculate average
IF windowSizeReached THEN
    average := sum / windowSize;
ELSE
    // Use current number of elements in buffer
    average := sum / (bufferIndex - 1);
END_IF;

END_FUNCTION_BLOCK