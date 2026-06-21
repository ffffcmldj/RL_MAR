plaintext
START_ST
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
    state : INT; (* The current state of the FSM *)
    prevState : INT; (* The previous state of the FSM *)
    dataBuffer : ARRAY[1..100] OF REAL; (* Buffer to store the data values *)
    bufferIndex : INT := 1; (* Index to track the current position in the buffer *)
    sum : REAL := 0.0; (* Sum of the data values in the buffer *)
    currentWindowSize : INT := 0; (* The current number of valid data points in the buffer *)
    risingEdgeDetected : BOOL; (* Tracks the rising edge of the trigger signal *)
    previousTrigger : BOOL := FALSE; (* Stores the previous state of the trigger signal *)
END_VAR

(* State Machine Implementation *)
CASE state OF

    (* STATE 0: INITIALIZE *)
    0:
        average := 0.0;
        windowSizeReached := FALSE;
        error := FALSE;
        status := 16#0000;
        sum := 0.0;
        bufferIndex := 1;
        currentWindowSize := 0;
        FOR bufferIndex := 1 TO 100 DO
            dataBuffer[bufferIndex] := 0.0;
        END_FOR;
        bufferIndex := 1;
        state := 1; (* Transition to STATE 1 *)

    (* STATE 1: WAIT_FOR_INPUT *)
    1:
        risingEdgeDetected := trigger AND NOT previousTrigger;
        previousTrigger := trigger;

        IF reset THEN
            state := 4; (* Transition to STATE 4: RESET *)
        ELSIF (windowSize < 1 OR windowSize > 100) THEN
            state := 5; (* Transition to STATE 5: ERROR_HANDLING *)
        ELSIF cyclicExecution OR risingEdgeDetected THEN
            state := 2; (* Transition to STATE 2: UPDATE_BUFFER *)
        END_IF;

    (* STATE 2: UPDATE_BUFFER *)
    2:
        IF currentWindowSize = windowSize THEN
            sum := sum - dataBuffer[bufferIndex]; (* Subtract the oldest value *)
        ELSE
            currentWindowSize := currentWindowSize + 1; (* Increment window size if not yet full *)
        END_IF;

        dataBuffer[bufferIndex] := value; (* Add new value to the buffer *)
        sum := sum + value; (* Add new value to the sum *)

        bufferIndex := bufferIndex + 1; (* Increment buffer index *)
        IF bufferIndex > windowSize THEN
            bufferIndex := 1; (* Wrap around if index exceeds window size *)
        END_IF;

        state := 3; (* Transition to STATE 3: CALCULATE_AVERAGE *)

    (* STATE 3: CALCULATE_AVERAGE *)
    3:
        IF currentWindowSize > 0 THEN
            average := sum / currentWindowSize; (* Calculate the moving average *)
        ELSE
            average := 0.0; (* Default to 0 if no valid data points *)
        END_IF;

        windowSizeReached := (currentWindowSize = windowSize); (* Check if window size is reached *)
        state := 1; (* Transition back to STATE 1: WAIT_FOR_INPUT *)

    (* STATE 4: RESET *)
    4:
        average := 0.0;
        windowSizeReached := FALSE;
        error := FALSE;
        status := 16#0000;
        sum := 0.0;
        bufferIndex := 1;
        currentWindowSize := 0;
        FOR bufferIndex := 1 TO 100 DO
            dataBuffer[bufferIndex] := 0.0;
        END_FOR;
        bufferIndex := 1;
        state := 1; (* Transition back to STATE 1: WAIT_FOR_INPUT *)

    (* STATE 5: ERROR_HANDLING *)
    5:
        error := TRUE;
        status := 16#8200; (* Window length setting error *)
        IF reset THEN
            state := 4; (* Transition to STATE 4: RESET *)
        END_IF;

END_CASE;

END_FUNCTION_BLOCK
END_ST