FUNCTION_BLOCK FB_SplitNumber
VAR_INPUT
    InputNumber : INT;
END_VAR

VAR_OUTPUT
    Thousands : INT;
    Hundreds : INT;
    Tens : INT;
    Ones : INT;
    Min : INT;
    error : BOOL;
    status : WORD;
END_VAR

VAR
    tempNumber : INT;
    minValue : INT;
    digitProcessed : BOOL;
END_VAR

(* Input Validation *)
IF (InputNumber < 0) OR (InputNumber > 9999) THEN
    (* Error case: Input out of valid range *)
    error := TRUE;
    status := 16#8001;
    
    (* Zero all outputs *)
    Thousands := 0;
    Hundreds := 0;
    Tens := 0;
    Ones := 0;
    Min := 0;
ELSE
    (* Valid case: Normal operation *)
    error := FALSE;
    status := 16#0000;
    
    (* Digit Separation Logic *)
    tempNumber := InputNumber;
    Thousands := tempNumber / 1000;
    tempNumber := tempNumber MOD 1000;
    Hundreds := tempNumber / 100;
    tempNumber := tempNumber MOD 100;
    Tens := tempNumber / 10;
    Ones := tempNumber MOD 10;
    
    (* Minimum Non-Zero Digit Detection *)
    minValue := 0;
    digitProcessed := FALSE;
    
    (* Process each digit sequentially, excluding zeros *)
    IF Thousands <> 0 THEN
        minValue := Thousands;
        digitProcessed := TRUE;
    END_IF;
    
    IF Hundreds <> 0 THEN
        IF digitProcessed THEN
            minValue := minimal(minValue, Hundreds);
        ELSE
            minValue := Hundreds;
            digitProcessed := TRUE;
        END_IF;
    END_IF;
    
    IF Tens <> 0 THEN
        IF digitProcessed THEN
            minValue := minimal(minValue, Tens);
        ELSE
            minValue := Tens;
            digitProcessed := TRUE;
        END_IF;
    END_IF;
    
    IF Ones <> 0 THEN
        IF digitProcessed THEN
            minValue := minimal(minValue, Ones);
        ELSE
            minValue := Ones;
            digitProcessed := TRUE;
        END_IF;
    END_IF;
    
    (* Set final Min output *)
    IF NOT digitProcessed THEN
        (* All digits were zero *)
        Min := 0;
    ELSE
        Min := minValue;
    END_IF;
END_IF;

END_FUNCTION_BLOCK

(* Provided minimal function *)
FUNCTION minimal : INT
VAR_INPUT
    IN1 : INT;
    IN2 : INT;
END_VAR

IF IN1 <= IN2 THEN
    minimal := IN1;
ELSE
    minimal := IN2;
END_IF;

END_FUNCTION