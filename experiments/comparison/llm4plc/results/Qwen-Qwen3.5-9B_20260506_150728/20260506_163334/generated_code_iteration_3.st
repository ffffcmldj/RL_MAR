START_REASON
The previous code failed because the `minimal` function was defined as a standalone `FUNCTION` but was not called anywhere in the `FB_SplitNumber` block. In IEC 61131-3 Structured Text, a `FUNCTION` cannot be instantiated (called) directly by name unless it is explicitly invoked. Furthermore, the logic for finding the minimum digit was implemented using a series of `IF` statements and a helper variable `minValue`, which is inefficient and likely not what was intended if a `minimal` function was defined.

To fix this:
1.  **Remove the unused `minimal` function**: Since the logic for finding the minimum was already hard-coded in the main block and the function was never called, removing it resolves the "cannot be instantiated" error and cleans up the code.
2.  **Simplify the logic**: The logic inside `FB_SplitNumber` for finding the minimum non-zero digit is correct and does not require an external function call.
3.  **Ensure Syntax Compliance**: Verify that all `VAR` sections end with `END_VAR` and the block ends correctly.
4.  **Remove Non-ASCII Characters**: Ensure all comments are in English to prevent encoding issues.

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
END_ST