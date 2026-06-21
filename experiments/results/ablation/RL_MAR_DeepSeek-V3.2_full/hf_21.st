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
END_VAR

// Main logic
IF (InputNumber < 0) OR (InputNumber > 9999) THEN
    // Error condition
    error := TRUE;
    status := 16#8001;
    Thousands := 0;
    Hundreds := 0;
    Tens := 0;
    Ones := 0;
    Min := 0;
ELSE
    // Valid input - process normally
    error := FALSE;
    status := 0;
    
    // Digit separation
    Thousands := InputNumber / 1000;
    Hundreds := (InputNumber MOD 1000) / 100;
    Tens := (InputNumber MOD 100) / 10;
    Ones := InputNumber MOD 10;
    
    // Find minimum non-zero digit
    minValue := 32767;
    
    IF (Thousands <> 0) THEN
        minValue := minimal(minValue, Thousands);
    END_IF;
    
    IF (Hundreds <> 0) THEN
        minValue := minimal(minValue, Hundreds);
    END_IF;
    
    IF (Tens <> 0) THEN
        minValue := minimal(minValue, Tens);
    END_IF;
    
    IF (Ones <> 0) THEN
        minValue := minimal(minValue, Ones);
    END_IF;
    
    // Set Min output
    IF (minValue = 32767) THEN
        Min := 0;  // All digits were zero
    ELSE
        Min := minValue;
    END_IF;
END_IF;

END_FUNCTION_BLOCK

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