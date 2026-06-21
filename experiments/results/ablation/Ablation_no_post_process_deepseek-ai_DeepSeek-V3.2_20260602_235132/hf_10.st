TYPE
    // Define a circular buffer structure for clarity and maintainability
    CircularBuffer : STRUCT
        Data : ARRAY[1..100] OF REAL;
        Head : INT; // Points to the oldest element (next to be overwritten)
        Count : INT; // Number of valid elements currently in the buffer
        Sum : REAL;
    END_STRUCT;
END_TYPE

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
    // Internal state variables
    Buffer : CircularBuffer;
    triggerPrev : BOOL := FALSE;
    windowSizeInternal : INT := 1;
    // Constants for status codes
    STATUS_OK : WORD := 16#0000;
    STATUS_WINDOW_ERROR : WORD := 16#8200;
END_VAR

// ========== MAIN LOGIC ==========

// 1. Handle RESET signal with highest priority
IF reset THEN
    // Reset the internal buffer state
    Buffer.Head := 1;
    Buffer.Count := 0;
    Buffer.Sum := 0.0;
    // Clear the buffer array (optional for clarity, but Count=0 makes them irrelevant)
    FOR i := 1 TO 100 DO
        Buffer.Data[i] := 0.0;
    END_FOR;
    
    // Reset outputs
    average := 0.0;
    windowSizeReached := FALSE;
    error := FALSE;
    status := STATUS_OK;
    
    // Reset internal tracking
    windowSizeInternal := 1;
    triggerPrev := FALSE;
    
    RETURN; // Exit the function block, no further processing this cycle
END_IF;

// 2. Validate windowSize on EVERY execution (not just on reset)
IF (windowSize < 1) OR (windowSize > 100) THEN
    // Set error state, do NOT process any new data
    error := TRUE;
    status := STATUS_WINDOW_ERROR;
    average := 0.0;
    windowSizeReached := FALSE;
    
    // Preserve internal state (no updates)
    triggerPrev := trigger; // Still update edge detection to avoid stuck trigger
    RETURN; // Exit the function block, no further processing this cycle
ELSE
    // Window size is valid, clear any previous error
    error := FALSE;
    status := STATUS_OK;
    windowSizeInternal := windowSize; // Store the valid size for internal use
END_IF;

// 3. Determine if a new value should be processed
//    Priority: cyclicExecution overrides trigger
IF cyclicExecution THEN
    // Process the new value immediately in cyclic mode
    ProcessNewValue(value);
ELSIF trigger AND NOT triggerPrev THEN
    // Process the new value on the rising edge of trigger
    ProcessNewValue(value);
END_IF;

// 4. Update edge detection for the trigger signal
triggerPrev := trigger;

// 5. Calculate and set the output average
IF Buffer.Count > 0 THEN
    average := Buffer.Sum / INT_TO_REAL(Buffer.Count);
ELSE
    average := 0.0;
END_IF;

// 6. Set the windowSizeReached flag
windowSizeReached := (Buffer.Count >= windowSizeInternal);

// ========== INTERNAL FUNCTION ==========
// Encapsulates the core buffer update logic for clarity and reuse
METHOD ProcessNewValue : BOOL
VAR_INPUT
    newValue : REAL;
END_VAR
VAR
    oldestValue : REAL;
END_VAR

    // If buffer is already at full window size, we need to remove the oldest value
    IF Buffer.Count >= windowSizeInternal THEN
        // The oldest value is at the current Head position
        oldestValue := Buffer.Data[Buffer.Head];
        Buffer.Sum := Buffer.Sum - oldestValue;
        
        // Overwrite the oldest value with the new one
        Buffer.Data[Buffer.Head] := newValue;
        Buffer.Sum := Buffer.Sum + newValue;
        
        // Move Head to the next position (circular)
        Buffer.Head := Buffer.Head + 1;
        IF Buffer.Head > windowSizeInternal THEN
            Buffer.Head := 1;
        END_IF;
        // Count remains unchanged (windowSizeInternal)
    ELSE
        // Buffer is not yet full, simply add the new value
        // Insert at position: Head + Count (since Head points to first element when full)
        // When not full, we can just append sequentially
        Buffer.Count := Buffer.Count + 1;
        Buffer.Data[Buffer.Count] := newValue;
        Buffer.Sum := Buffer.Sum + newValue;
        // Head remains at 1 until the buffer fills for the first time
    END_IF;
    
    ProcessNewValue := TRUE; // Success
END_METHOD

END_FUNCTION_BLOCK;