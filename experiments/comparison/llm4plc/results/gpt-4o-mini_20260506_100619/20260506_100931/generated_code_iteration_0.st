ructured-text
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
    state : INT; (* The state variable *)
    prevState : INT; (* The previous state variable *)
END_VAR

(* Initialize state *)
state := 0;
average := 0.0;
windowSizeReached := FALSE;
error := FALSE;
status := 16#0000;

(* Main execution loop *)
IF reset THEN
    state := 3; (* Go to RESET state *)
END_IF

CASE state OF
    0: (* INITIALIZE state *)
        IF (cyclicExecution OR (trigger AND NOT prevState)) THEN
            state := 1; (* Go to UPDATE AVERAGE state *)
        END_IF

    1: (* UPDATE AVERAGE state *)
        IF (windowSize < 1 OR windowSize > 100) THEN
            state := 2; (* Go to ERROR HANDLING state *)
        ELSE
            IF cyclicExecution THEN
                dataBuffer[bufferIndex] := value; (* Store the new value in the buffer *)
                sum := sum + value - dataBuffer[bufferIndex]; (* Update the sum *)
                bufferIndex := (bufferIndex MOD windowSize) + 1; (* Update buffer index cyclically *)
                IF bufferIndex = 1 THEN
                    windowSizeReached := TRUE; (* Maximum window width has been reached *)
                END_IF
                average := sum / windowSize; (* Calculate the moving average *)
            END_IF

            IF trigger AND NOT prevState THEN
                dataBuffer[bufferIndex] := value; (* Store the new value in the buffer *)
                sum := sum + value - dataBuffer[bufferIndex]; (* Update the sum *)
                bufferIndex := (bufferIndex MOD windowSize) + 1; (* Update buffer index cyclically *)
                IF bufferIndex = 1 THEN
                    windowSizeReached := TRUE; (* Maximum window width has been reached *)
                END_IF
                average := sum / windowSize; (* Calculate the moving average *)
            END_IF

            error := FALSE; (* No error occurred *)
            status := 16#0000; (* Execution successful *)
        END_IF

    2: (* ERROR HANDLING state *)
        average := 0.0; (* Reset average *)
        windowSizeReached := FALSE;
        error := TRUE; (* An error occurred *)
        status := 16#8200; (* Window length setting error *)

    3: (* RESET state *)
        average := 0.0; (* Reset average *)
        windowSizeReached := FALSE;
        error := FALSE; (* No error occurred *)
        status := 16#0000; (* Execution successful *)
        state := 0; (* Go back to INITIALIZE state *)

END_CASE

prevState := trigger; (* Update previous state for edge detection *)

END_FUNCTION_BLOCK