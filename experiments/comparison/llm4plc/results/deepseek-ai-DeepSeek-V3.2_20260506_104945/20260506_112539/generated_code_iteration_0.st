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
    state : INT;
    prevState : INT;
    tempNumber : INT;
    minValue : INT;
END_VAR

CASE state OF
    0: (* STATE 0: INITIALIZE AND VALIDATE INPUT *)
        (* Reset all output variables *)
        Thousands := 0;
        Hundreds := 0;
        Tens := 0;
        Ones := 0;
        Min := 0;
        error := FALSE;
        status := 16#0000;
        (* Validate InputNumber range *)
        IF (InputNumber >= 0) AND (InputNumber <= 9999) THEN
            state := 1; (* Transition to STATE 1 *)
        ELSE
            state := 3; (* Transition to STATE 3 *)
        END_IF;

    1: (* STATE 1: SEPARATE DIGITS *)
        (* Calculate digit values using division and modulo *)
        Thousands := InputNumber / 1000;
        Hundreds := (InputNumber MOD 1000) / 100;
        Tens := (InputNumber MOD 100) / 10;
        Ones := InputNumber MOD 10;
        state := 2; (* Transition to STATE 2 *)

    2: (* STATE 2: FIND MINIMUM NON-ZERO DIGIT *)
        (* Initialize minValue to maximum INT *)
        minValue := 32767;
        (* Check Thousands digit *)
        IF Thousands <> 0 THEN
            minValue := minimal(minValue, Thousands);
        END_IF;
        (* Check Hundreds digit *)
        IF Hundreds <> 0 THEN
            minValue := minimal(minValue, Hundreds);
        END_IF;
        (* Check Tens digit *)
        IF Tens <> 0 THEN
            minValue := minimal(minValue, Tens);
        END_IF;
        (* Check Ones digit *)
        IF Ones <> 0 THEN
            minValue := minimal(minValue, Ones);
        END_IF;
        (* Determine Min output *)
        IF minValue = 32767 THEN
            Min := 0; (* All digits were zero *)
        ELSE
            Min := minValue;
        END_IF;
        state := 0; (* Transition back to STATE 0 for next cycle *)

    3: (* STATE 3: ERROR HANDLING *)
        (* Set error outputs *)
        error := TRUE;
        status := 16#8001;
        (* Zero all digit outputs *)
        Thousands := 0;
        Hundreds := 0;
        Tens := 0;
        Ones := 0;
        Min := 0;
        state := 0; (* Transition back to STATE 0 for next cycle *)

    ELSE
        (* Default case: reset to STATE 0 *)
        state := 0;
END_CASE;

(* Store current state for tracking if needed *)
prevState := state;

END_FUNCTION_BLOCK

END_ST