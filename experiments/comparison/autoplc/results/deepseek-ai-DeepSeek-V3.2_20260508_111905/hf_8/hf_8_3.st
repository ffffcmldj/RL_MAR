FUNCTION_BLOCK FB_HexDigitAnalyzer
VAR_INPUT
    InputNumber : INT; (* Input integer value (0 to 9999) *)
END_VAR

VAR_OUTPUT
    Thousands : INT; (* Thousands place digit (0-9) *)
    Hundreds : INT;  (* Hundreds place digit (0-9) *)
    Tens : INT;      (* Tens place digit (0-9) *)
    Ones : INT;      (* Ones place digit (0-9) *)
    MinDigit : INT;  (* Minimum non-zero digit among all separated digits *)
    error : BOOL;    (* Error state indicator *)
    status : WORD;   (* Error code *)
END_VAR

VAR
    tempValue : INT;
    minValue : INT;
    digit : INT;
    i : INT;
END_VAR

(* Input Validation *)
IF (InputNumber < 0) OR (InputNumber > 9999) THEN
    (* Error condition *)
    error := TRUE;
    status := 16#8001;
    
    (* Set all outputs to 0 *)
    Thousands := 0;
    Hundreds := 0;
    Tens := 0;
    Ones := 0;
    MinDigit := 0;
ELSE
    (* Valid input *)
    error := FALSE;
    status := 16#0000;
    
    (* Digit Separation Logic *)
    Thousands := InputNumber / 1000;
    
    tempValue := InputNumber MOD 1000;
    Hundreds := tempValue / 100;
    
    tempValue := InputNumber MOD 100;
    Tens := tempValue / 10;
    
    Ones := InputNumber MOD 10;
    
    (* Minimum Value Detection *)
    minValue := 32767; (* Maximum possible INT value *)
    
    (* Check Thousands digit *)
    IF Thousands > 0 THEN
        minValue := MIN(Thousands, minValue);
    END_IF;
    
    (* Check Hundreds digit *)
    IF Hundreds > 0 THEN
        minValue := MIN(Hundreds, minValue);
    END_IF;
    
    (* Check Tens digit *)
    IF Tens > 0 THEN
        minValue := MIN(Tens, minValue);
    END_IF;
    
    (* Check Ones digit *)
    IF Ones > 0 THEN
        minValue := MIN(Ones, minValue);
    END_IF;
    
    (* Set MinDigit output *)
    IF minValue = 32767 THEN
        (* All digits are zero *)
        MinDigit := 0;
    ELSE
        MinDigit := minValue;
    END_IF;
END_IF;
END_FUNCTION_BLOCK