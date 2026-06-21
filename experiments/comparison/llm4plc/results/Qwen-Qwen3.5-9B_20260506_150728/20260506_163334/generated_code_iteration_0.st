START_ST
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
    isAllZero : BOOL;
END_VAR

BEGIN
    (* STATE 0: INITIALIZE *)
    (* Reset outputs and prepare for validation *)
    Thousands := 0;
    Hundreds := 0;
    Tens := 0;
    Ones := 0;
    Min := 0;
    error := FALSE;
    status := 0;
    
    (* STATE 1: VALIDATE_INPUT *)
    (* Check range and set error flags *)
    IF (InputNumber < 0) OR (InputNumber > 9999) THEN
        error := TRUE;
        status := 16#8001;
        (* Outputs remain 0 as per requirement *)
    ELSE
        (* STATE 2: SEPARATE_DIGITS *)
        (* Extract Thousands, Hundreds, Tens, Ones *)
        tempNumber := InputNumber;
        Thousands := tempNumber DIV 1000;
        tempNumber := tempNumber MOD 1000;
        Hundreds := tempNumber DIV 100;
        tempNumber := tempNumber MOD 100;
        Tens := tempNumber DIV 10;
        Ones := tempNumber MOD 10;
        
        (* STATE 3: CALCULATE_MIN *)
        (* Find minimum non-zero digit *)
        minValue := 32767; (* Maximum possible INT value *)
        isAllZero := TRUE;
        
        (* Check Thousands *)
        IF Thousands <> 0 THEN
            IF minValue > Thousands THEN
                minValue := Thousands;
            END_IF;
            isAllZero := FALSE;
        END_IF;
        
        (* Check Hundreds *)
        IF Hundreds <> 0 THEN
            IF minValue > Hundreds THEN
                minValue := Hundreds;
            END_IF;
            isAllZero := FALSE;
        END_IF;
        
        (* Check Tens *)
        IF Tens <> 0 THEN
            IF minValue > Tens THEN
                minValue := Tens;
            END_IF;
            isAllZero := FALSE;
        END_IF;
        
        (* Check Ones *)
        IF Ones <> 0 THEN
            IF minValue > Ones THEN
                minValue := Ones;
            END_IF;
            isAllZero := FALSE;
        END_IF;
        
        (* Assign Min based on calculation *)
        IF isAllZero THEN
            Min := 0;
        ELSE
            Min := minValue;
        END_IF;
        
        (* STATE 4: FINALIZE *)
        (* Set final outputs and status *)
        error := FALSE;
        status := 0;
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
END_ST