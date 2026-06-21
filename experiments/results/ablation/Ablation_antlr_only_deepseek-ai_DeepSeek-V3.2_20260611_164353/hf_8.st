FUNCTION_BLOCK FB_HexDigitAnalyzer
VAR_INPUT
    InputNumber : INT;
END_VAR
VAR_OUTPUT
    Thousands : INT;
    Hundreds : INT;
    Tens : INT;
    Ones : INT;
    MinDigit : INT;
    error : BOOL;
    status : WORD;
END_VAR
VAR
    tempMin : INT;
    digitVal : INT;
END_VAR

(* Input Validation *)
IF (InputNumber < 0) OR (InputNumber > 9999) THEN
    (* Error Condition *)
    error := TRUE;
    status := 16#8001;
    Thousands := 0;
    Hundreds := 0;
    Tens := 0;
    Ones := 0;
    MinDigit := 0;
ELSE
    (* Valid Input Processing *)
    error := FALSE;
    status := 16#0000;
    
    (* Digit Separation *)
    Thousands := InputNumber / 1000;
    Hundreds := (InputNumber MOD 1000) / 100;
    Tens := (InputNumber MOD 100) / 10;
    Ones := InputNumber MOD 10;
    
    (* Minimum Non-Zero Digit Detection *)
    tempMin := 32767; (* Maximum INT value *)
    
    (* Check Thousands digit *)
    digitVal := Thousands;
    IF digitVal <> 0 THEN
        tempMin := minimal(tempMin, digitVal);
    END_IF;
    
    (* Check Hundreds digit *)
    digitVal := Hundreds;
    IF digitVal <> 0 THEN
        tempMin := minimal(tempMin, digitVal);
    END_IF;
    
    (* Check Tens digit *)
    digitVal := Tens;
    IF digitVal <> 0 THEN
        tempMin := minimal(tempMin, digitVal);
    END_IF;
    
    (* Check Ones digit *)
    digitVal := Ones;
    IF digitVal <> 0 THEN
        tempMin := minimal(tempMin, digitVal);
    END_IF;
    
    (* Determine final MinDigit output *)
    IF tempMin = 32767 THEN
        (* No non-zero digits found *)
        MinDigit := 0;
    ELSE
        MinDigit := tempMin;
    END_IF;
END_IF;

END_FUNCTION_BLOCK;