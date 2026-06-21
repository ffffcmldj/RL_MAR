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
        bufferIndex : INT; (* Index to track the current position in the buffer *)
        sum : REAL; (* Sum of the data values in the buffer *)
        i : INT; (* Loop variable *)
    END_VAR

    (* Initialize buffer index and sum in the execution logic *)
    IF NOT reset THEN
        bufferIndex := 1; (* Initialize buffer index *)
        sum := 0.0; (* Initialize sum *)
    END_IF

    (* Error checking for window size *)
    IF windowSize < 1 OR windowSize > 100 THEN
        error := TRUE;
        status := 16#8200; (* Window length setting error *)
    ELSE
        error := FALSE;
        status := 16#0000; (* Execution successful *)

        (* Reset logic *)
        IF reset THEN
            sum := 0.0;
            FOR i := 1 TO 100 DO
                dataBuffer[i] := 0.0; (* Clear the buffer *)
            END_FOR
            bufferIndex := 1; (* Reset buffer index *)
        ELSE
            (* Update moving average on cyclic execution or trigger *)
            IF cyclicExecution OR (trigger AND NOT trigger) THEN
                (* Replace the oldest value in the buffer with the new value *)
                sum := sum - dataBuffer[bufferIndex]; (* Subtract the old value *)
                dataBuffer[bufferIndex] := value; (* Store the new value *)
                sum := sum + value; (* Add the new value *)

                (* Increment buffer index and wrap around if necessary *)
                bufferIndex := bufferIndex + 1;
                IF bufferIndex > windowSize THEN
                    bufferIndex := 1; (* Wrap around to the start of the buffer *)
                END_IF
            END_IF
        END_IF

        (* Calculate the average *)
        average := sum / REAL(MIN(bufferIndex - 1, windowSize)); (* Use MIN to avoid division by zero *)

        (* Check if the window size has been reached *)
        IF bufferIndex - 1 >= windowSize THEN
            windowSizeReached := TRUE;
        ELSE
            windowSizeReached := FALSE;
        END_IF
    END_IF
END_FUNCTION_BLOCK