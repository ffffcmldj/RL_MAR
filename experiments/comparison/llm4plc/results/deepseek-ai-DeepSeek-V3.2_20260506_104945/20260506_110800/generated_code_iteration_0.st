START_ST
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
    state : INT := 0;
    prevTrigger : BOOL := FALSE;
    internalReset : BOOL := FALSE;
    tempWindowSize : INT;
    i : INT;
END_VAR

    (* State Machine Execution *)
    CASE state OF
        0: (* IDLE *)
            (* Check for reset condition *)
            IF reset THEN
                (* Clear internal state *)
                sum := 0.0;
                average := 0.0;
                windowSizeReached := FALSE;
                error := FALSE;
                status := 16#0000;
                bufferIndex := 1;
                FOR i := 1 TO 100 DO
                    dataBuffer[i] := 0.0;
                END_FOR;
                internalReset := TRUE;
            END_IF;

            (* Validate windowSize *)
            IF (windowSize < 1) OR (windowSize > 100) THEN
                state := 2; (* Transition to ERROR state *)
            ELSE
                tempWindowSize := windowSize;
                (* Check for processing condition *)
                IF (cyclicExecution OR (trigger AND NOT prevTrigger)) AND NOT internalReset THEN
                    state := 1; (* Transition to PROCESSING state *)
                END_IF;
            END_IF;

            (* Update trigger memory for edge detection *)
            prevTrigger := trigger;

            (* Clear internal reset flag if reset is no longer active *)
            IF NOT reset THEN
                internalReset := FALSE;
            END_IF;

        1: (* PROCESSING *)
            (* Store old value at current buffer index before overwriting *)
            IF bufferIndex > tempWindowSize THEN
                (* Buffer is full, subtract the oldest value *)
                sum := sum - dataBuffer[((bufferIndex - 1) MOD tempWindowSize) + 1];
            END_IF;

            (* Add new value to buffer and update sum *)
            dataBuffer[((bufferIndex - 1) MOD tempWindowSize) + 1] := value;
            sum := sum + value;

            (* Calculate average *)
            IF bufferIndex <= tempWindowSize THEN
                average := sum / bufferIndex;
            ELSE
                average := sum / tempWindowSize;
            END_IF;

            (* Update windowSizeReached *)
            windowSizeReached := (bufferIndex >= tempWindowSize);

            (* Update buffer index with wrap-around *)
            bufferIndex := bufferIndex + 1;
            IF bufferIndex > 100 THEN
                bufferIndex := 1; (* Safety wrap, though tempWindowSize <= 100 *)
            END_IF;

            (* Set outputs *)
            error := FALSE;
            status := 16#0000;

            (* Return to IDLE state *)
            state := 0;

        2: (* ERROR *)
            error := TRUE;
            status := 16#8200;
            average := 0.0;
            windowSizeReached := FALSE;

            (* Check for recovery condition *)
            IF reset AND (windowSize >= 1) AND (windowSize <= 100) THEN
                (* Perform reset and transition to IDLE *)
                sum := 0.0;
                bufferIndex := 1;
                FOR i := 1 TO 100 DO
                    dataBuffer[i] := 0.0;
                END_FOR;
                internalReset := TRUE;
                state := 0;
            END_IF;

    END_CASE;

END_FUNCTION_BLOCK
END_ST