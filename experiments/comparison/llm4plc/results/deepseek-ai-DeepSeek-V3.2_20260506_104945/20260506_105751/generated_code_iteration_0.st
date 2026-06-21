START_ST
FUNCTION_BLOCK RandomNumberGenerator
VAR_INPUT
    minValue : DINT;
    maxValue : DINT;
    randomSeed_in : DINT;
END_VAR
VAR_OUTPUT
    error : BOOL;
    status : WORD;
    randomNumber : DINT;
END_VAR
VAR
    state : INT;
    prevState : INT;
    internalSeed : DINT;
    range : DINT;
    tempRandom : DINT;
END_VAR

CASE state OF
    0: (* STATE 0: INITIALIZE / IDLE *)
        (* Outputs: error = FALSE (or previous value held), status = 16#0000 (or previous), randomNumber = 0 (or previous) *)
        (* No forced output changes here to hold previous values *)
        (* Transition: On every scan cycle when the function block is called, transition immediately to validation. *)
        state := 1;
        prevState := 0;

    1: (* STATE 1: VALIDATE RANGE *)
        IF minValue > maxValue THEN
            (* Range error: set outputs and return to idle *)
            error := TRUE;
            status := 16#8200;
            randomNumber := 0;
            state := 0;
        ELSE
            (* Range valid: set outputs and proceed to generation *)
            error := FALSE;
            status := 16#0000;
            state := 2;
        END_IF;
        prevState := 1;

    2: (* STATE 2: GENERATE RANDOM NUMBER *)
        (* Ensure seed is positive: use absolute value *)
        internalSeed := ABS(randomSeed_in);
        IF internalSeed = 0 THEN
            internalSeed := 1; (* Avoid zero seed to prevent modulo issues *)
        END_IF;

        (* Compute range for modulo operation *)
        range := maxValue - minValue + 1;
        IF range <= 0 THEN
            (* Should not happen as validated in state 1, but as safety fallback *)
            error := TRUE;
            status := 16#8200;
            randomNumber := 0;
        ELSE
            (* Generate random number using modulo arithmetic *)
            tempRandom := internalSeed MOD 32768; (* Simple pseudo-random step *)
            tempRandom := (tempRandom * 1103515245 + 12345) MOD 2147483648; (* Linear congruential generator for better distribution *)
            tempRandom := ABS(tempRandom);
            randomNumber := minValue + (tempRandom MOD range);

            (* Set outputs *)
            error := FALSE;
            status := 16#0000;
        END_IF;

        (* Return to idle *)
        state := 0;
        prevState := 2;

    ELSE
        (* Fallback: reset to state 0 *)
        state := 0;
END_CASE;
END_FUNCTION_BLOCK
END_ST