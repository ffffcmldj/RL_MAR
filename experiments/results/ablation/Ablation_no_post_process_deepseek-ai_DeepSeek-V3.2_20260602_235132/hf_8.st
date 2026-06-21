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
    tempMinValue : INT;
END_VAR

(* Input Validation *)
IF (InputNumber < 0) OR (InputNumber > 9999) THEN
    error := TRUE;
    status := 16#8001;
    Thousands := 0;
    Hundreds := 0;
    Tens := 0;
    Ones := 0;
    MinDigit := 0;
ELSE
    error := FALSE;
    status := 16#0000;
    
    (* Digit Separation Logic *)
    Thousands := InputNumber / 1000;
    Hundreds := (InputNumber MOD 1000) / 100;
    Tens := (InputNumber MOD 100) / 10;
    Ones := InputNumber MOD 10;
    
    (* Minimum Non-Zero Digit Detection *)
    tempMinValue := 32767; (* Maximum INT value *)
    
    IF Thousands <> 0 THEN
        tempMinValue := minimal(tempMinValue, Thousands);
    END_IF;
    
    IF Hundreds <> 0 THEN
        tempMinValue := minimal(tempMinValue, Hundreds);
    END_IF;
    
    IF Tens <> 0 THEN
        tempMinValue := minimal(tempMinValue, Tens);
    END_IF;
    
    IF Ones <> 0 THEN
        tempMinValue := minimal(tempMinValue, Ones);
    END_IF;
    
    (* Final MinDigit Assignment *)
    IF tempMinValue = 32767 THEN
        MinDigit := 0; (* All digits were zero *)
    ELSE
        MinDigit := tempMinValue;
    END_IF;
END_IF;

END_FUNCTION_BLOCK;