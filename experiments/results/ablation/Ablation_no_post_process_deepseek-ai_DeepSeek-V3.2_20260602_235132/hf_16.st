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

VAR_GLOBAL CONSTANT
    gc_Segments : ARRAY[1..3] OF ST_LinearSegment := [
        (InputMin := 1200.0, InputMax := 3600.0, OutputMin := 150.0, OutputMax := 240.0),
        (InputMin := 3600.0, InputMax := 4800.0, OutputMin := 240.0, OutputMax := 560.0),
        (InputMin := 4800.0, InputMax := 7000.0, OutputMin := 560.0, OutputMax := 720.0)
    ];
    gc_InputMinLimit : REAL := 1200.0;
    gc_InputMaxLimit : REAL := 7000.0;
    gc_OutputMinLimit : REAL := 150.0;
    gc_OutputMaxLimit : REAL := 720.0;
END_VAR

FUNCTION_BLOCK FB_LinearizeValue
VAR_INPUT
    InputValue : REAL;
END_VAR

VAR_OUTPUT
    LinearizedValue : REAL;
    Error : BOOL;
    Status : WORD;
END_VAR

VAR
    iSegmentIndex : INT;
    bValueProcessed : BOOL;
END_VAR

(* Initialize outputs *)
LinearizedValue := 0.0;
Error := FALSE;
Status := E_StatusCode.STATUS_OK;
bValueProcessed := FALSE;

(* Check for out-of-range conditions *)
IF InputValue < gc_InputMinLimit THEN
    LinearizedValue := gc_OutputMinLimit;
    Error := TRUE;
    Status := E_StatusCode.STATUS_OUT_OF_RANGE;
    bValueProcessed := TRUE;
ELSIF InputValue > gc_InputMaxLimit THEN
    LinearizedValue := gc_OutputMaxLimit;
    Error := TRUE;
    Status := E_StatusCode.STATUS_OUT_OF_RANGE;
    bValueProcessed := TRUE;
END_IF;

(* Process valid ranges if not already handled *)
IF NOT bValueProcessed THEN
    FOR iSegmentIndex := 1 TO 3 DO
        IF (InputValue >= gc_Segments[iSegmentIndex].InputMin) 
           AND (InputValue <= gc_Segments[iSegmentIndex].InputMax) THEN
            LinearizedValue := gc_Segments[iSegmentIndex].OutputMin 
                + (InputValue - gc_Segments[iSegmentIndex].InputMin) 
                * (gc_Segments[iSegmentIndex].OutputMax - gc_Segments[iSegmentIndex].OutputMin)
                / (gc_Segments[iSegmentIndex].InputMax - gc_Segments[iSegmentIndex].InputMin);
            Error := FALSE;
            Status := E_StatusCode.STATUS_OK;
            bValueProcessed := TRUE;
            EXIT;
        END_IF;
    END_FOR;
END_IF;

(* Handle edge case: value within global limits but not in any segment *)
IF NOT bValueProcessed THEN
    LinearizedValue := 0.0;
    Error := TRUE;
    Status := E_StatusCode.STATUS_OUT_OF_RANGE;
END_IF;

END_FUNCTION_BLOCK;