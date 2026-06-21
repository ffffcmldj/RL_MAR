FUNCTION_BLOCK FloatingAverage
VAR_INPUT
    cyclicExecution : BOOL; // When TRUE, periodic reading is performed, and trigger has no effect
    trigger : BOOL; // External trigger signal, reads value upon each rising edge
    value : REAL; // Newly read data value
    windowSize : INT; // The window size for the moving average, which must be between 1 and 100
    reset : BOOL; // Reset signal, resets the moving average calculation when TRUE
END_VAR
VAR_OUTPUT
    average : REAL; // The moving average
    windowSizeReached : BOOL; // FALSE: Maximum window width not yet reached, TRUE: Maximum window width has been reached
    error : BOOL; // FALSE: No error occurred, TRUE: An error occurred during the execution of FB
    status : WORD; // Status code
END_VAR
VAR
    dataBuffer : ARRAY[1..100] OF REAL; // Buffer to store the data values
    bufferIndex : INT := 1; // Index to track the current position in the buffer
    sum : REAL := 0.0; // Sum of the data values in the buffer
    currentSize : INT := 0; // Current number of data points in the buffer
    lastTriggerState : BOOL := FALSE; // To detect rising edge of trigger
END_VAR

// Initialization and Validation
IF (windowSize < 1) OR (windowSize > 100) THEN
    error := TRUE;
    status := 16#8200; // Window length setting error
ELSE
    error := FALSE;
    status := 16#0000; // Execution successful
END_IF

// Reset Logic
IF reset THEN
    FOR bufferIndex := 1 TO 100 DO
        dataBuffer[bufferIndex] := 0.0;
    END_FOR
    bufferIndex := 1;
    sum := 0.0;
    average := 0.0;
    windowSizeReached := FALSE;
    currentSize := 0;
    error := FALSE;
    status := 16#0000; // Execution successful
END_IF

// Data Acquisition and Processing
IF NOT error THEN
    IF cyclicExecution OR (trigger AND NOT lastTriggerState) THEN
        // Update the Moving Average
        IF currentSize < windowSize THEN
            currentSize := currentSize + 1;
        ELSE
            sum := sum - dataBuffer[bufferIndex];
        END_IF

        dataBuffer[bufferIndex] := value;
        sum := sum + value;
        bufferIndex := bufferIndex + 1;

        IF bufferIndex > windowSize THEN
            bufferIndex := 1;
        END_IF

        // Calculate and Output the Moving Average
        IF currentSize < windowSize THEN
            average := sum / currentSize;
            windowSizeReached := FALSE;
        ELSE
            average := sum / windowSize;
            windowSizeReached := TRUE;
        END_IF
    END_IF
END_IF

// Update last trigger state
lastTriggerState := trigger;

END_FUNCTION_BLOCK