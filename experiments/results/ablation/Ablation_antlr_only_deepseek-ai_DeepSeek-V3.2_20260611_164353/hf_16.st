TYPE
    ST_LinearSegment : STRUCT
        InputMin : REAL;
        InputMax : REAL;
        OutputMin : REAL;
        OutputMax : REAL;
    END_STRUCT;

    E_StatusCode : (
        STATUS_OK := 16#0000,
        STATUS_OUT_OF_RANGE := 16#8001
    );
END_TYPE

FUNCTION_BLOCK FB_LinearizeValue
VAR_INPUT
    InputValue : REAL;
END_VAR

VAR_OUTPUT
    LinearizedValue : REAL := 0.0;
    Error : BOOL := FALSE;
    Status : WORD := 16#0000;
END_VAR

VAR
    // Internal constants for piecewise linear segments
    Segments : ARRAY[1..3] OF ST_LinearSegment := [
        (InputMin := 1200.0, InputMax := 3600.0, OutputMin := 150.0, OutputMax := 240.0),
        (InputMin := 3600.0, InputMax := 4800.0, OutputMin := 240.0, OutputMax := 560.0),
        (InputMin := 4800.0, InputMax := 7000.0, OutputMin := 560.0, OutputMax := 720.0)
    ];
    i : INT;
    FoundSegment : BOOL;
END_VAR

// Reset status flags
Error := FALSE;
Status := E_StatusCode.STATUS_OK;
LinearizedValue := 0.0;
FoundSegment := FALSE;

// Handle out-of-range conditions
IF InputValue < Segments[1].InputMin THEN
    LinearizedValue := Segments[1].OutputMin;
    Error := TRUE;
    Status := E_StatusCode.STATUS_OUT_OF_RANGE;
ELSIF InputValue > Segments[3].InputMax THEN
    LinearizedValue := Segments[3].OutputMax;
    Error := TRUE;
    Status := E_StatusCode.STATUS_OUT_OF_RANGE;
ELSE
    // Find appropriate segment and perform linear interpolation
    FOR i := 1 TO 3 DO
        IF (InputValue >= Segments[i].InputMin) AND (InputValue <= Segments[i].InputMax) THEN
            LinearizedValue := Segments[i].OutputMin + 
                              (InputValue - Segments[i].InputMin) * 
                              (Segments[i].OutputMax - Segments[i].OutputMin) / 
                              (Segments[i].InputMax - Segments[i].InputMin);
            FoundSegment := TRUE;
            EXIT;
        END_IF;
    END_FOR;
    
    // If no segment found (should not happen with proper range checking)
    IF NOT FoundSegment THEN
        LinearizedValue := 0.0;
        Error := TRUE;
        Status := E_StatusCode.STATUS_OUT_OF_RANGE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK;