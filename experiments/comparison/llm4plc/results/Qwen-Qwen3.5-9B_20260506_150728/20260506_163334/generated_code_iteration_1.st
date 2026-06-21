START_REASON
The error "发现非预期的记号'Min'" (Unexpected symbol 'Min') indicates a syntax violation in the Structured Text (ST) code. In IEC 61131-3 ST, variable names must start with a letter and can contain letters, digits, and underscores. However, the specific error usually points to one of two issues in this context:

1.  **Reserved Keyword Conflict**: While `Min` is not a standard reserved keyword in all PLC environments, some strict compilers or specific dialects might flag it if it conflicts with internal logic or if the naming convention is too close to reserved words like `MIN` (which is a function in some libraries). However, the most likely cause in CODESYS when seeing "Unexpected symbol" on a variable name is often a case sensitivity issue or a conflict with a built-in function if the compiler is confused.
2.  **More Likely Cause - Variable Declaration Scope/Name**: In many CODESYS versions, using `Min` as a variable name can be problematic if the compiler interprets it as a reference to a standard library function `MIN` or if there is a parsing ambiguity. A safer and more standard practice is to use descriptive names like `MinimumValue` or `MinDigit`.
3.  **Grammar Parsing**: Sometimes, if the variable name is too short or looks like a keyword, the parser fails. Renaming `Min` to `MinDigit` resolves this ambiguity completely.

Additionally, I will ensure all variable sections are closed correctly with `END_VAR` and maintain the `FUNCTION_BLOCK` structure as requested. The logic inside remains the same, but the variable name `Min` will be changed to `MinDigit` to satisfy the compiler.

END_REASON
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
    MinDigit : INT;
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
    MinDigit := 0;
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
        
        (* Assign MinDigit based on calculation *)
        IF isAllZero THEN
            MinDigit := 0;
        ELSE
            MinDigit := minValue;
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