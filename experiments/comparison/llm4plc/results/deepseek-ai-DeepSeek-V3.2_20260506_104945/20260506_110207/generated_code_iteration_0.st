START_ST
FUNCTION_BLOCK FB_HexDigitAnalyzer
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
    state : INT;
    prevState : INT;
    tempMin : INT;
    digit1 : INT;
    digit2 : INT;
    digit3 : INT;
    digit4 : INT;
END_VAR

CASE state OF
    0: (* STATE 0: INITIALIZE *)
        Thousands := 0;
        Hundreds := 0;
        Tens := 0;
        Ones := 0;
        Min := 0;
        error := FALSE;
        status := 16#0000;
        state := 1; (* Transition to STATE 1 *)

    1: (* STATE 1: VALIDATE_INPUT *)
        IF (InputNumber >= 0) AND (InputNumber <= 9999) THEN
            error := FALSE;
            status := 16#0000;
            state := 2; (* Valid input, go to digit separation *)
        ELSE
            state := 4; (* Invalid input, go to error handling *)
        END_IF;

    2: (* STATE 2: SEPARATE_DIGITS *)
        Thousands := InputNumber / 1000;
        Hundreds := (InputNumber MOD 1000) / 100;
        Tens := (InputNumber MOD 100) / 10;
        Ones := InputNumber MOD 10;
        state := 3; (* Transition to find minimum *)

    3: (* STATE 3: FIND_MIN_NONZERO_DIGIT *)
        tempMin := 32767; (* Initialize to maximum INT value *)

        digit1 := Thousands;
        IF digit1 <> 0 THEN
            tempMin := minimal(tempMin, digit1);
        END_IF;

        digit2 := Hundreds;
        IF digit2 <> 0 THEN
            tempMin := minimal(tempMin, digit2);
        END_IF;

        digit3 := Tens;
        IF digit3 <> 0 THEN
            tempMin := minimal(tempMin, digit3);
        END_IF;

        digit4 := Ones;
        IF digit4 <> 0 THEN
            tempMin := minimal(tempMin, digit4);
        END_IF;

        IF tempMin = 32767 THEN
            Min := 0; (* All digits were zero *)
        ELSE
            Min := tempMin;
        END_IF;
        state := 0; (* Processing complete, reset for next cycle *)

    4: (* STATE 4: ERROR_HANDLING *)
        Thousands := 0;
        Hundreds := 0;
        Tens := 0;
        Ones := 0;
        Min := 0;
        error := TRUE;
        status := 16#8001;
        state := 0; (* Error handled, reset for next cycle *)

END_CASE;

prevState := state; (* Optional: track previous state if needed for debugging *)

END_FUNCTION_BLOCK
END_ST