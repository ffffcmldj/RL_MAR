START_REASON
The previous code failed due to encoding issues. The error message "'gbk' codec can't decode byte 0xa2 in position 35" indicates that the code contained non-ASCII characters (likely Chinese comments like `(* STATE 0: INITIALIZE *)` or similar) which are not supported in the GBK encoding expected by the toolchain or the specific ST compiler configuration.

To fix this:
1.  **Remove all non-English comments**: Replace Chinese comments with English equivalents or remove them entirely to ensure pure ASCII/UTF-8 compatibility.
2.  **Verify Syntax**: Ensure all variable declarations use `END_VAR` correctly within their respective blocks (VAR_INPUT, VAR_OUTPUT, VAR).
3.  **Maintain Structure**: Keep the `FUNCTION_BLOCK` structure and the helper `FUNCTION` as requested.
4.  **Logic Check**: The logic for splitting digits and finding the minimum non-zero digit remains valid, but the text representation must be clean.

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