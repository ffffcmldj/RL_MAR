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
    workingSeed : DINT;
    rangeSize : DINT;
    rawRandom : DINT;
    scaledRandom : DINT;
END_VAR
    (* Initialize outputs *)
    error := FALSE;
    status := 16#0000;
    randomNumber := 0;
    
    (* Validate input range *)
    IF minValue > maxValue THEN
        error := TRUE;
        status := 16#8200;
        randomNumber := 0;
        RETURN;
    END_IF;
    
    (* Prepare seed: ensure positive and non-zero *)
    workingSeed := randomSeed_in;
    IF workingSeed < 0 THEN
        workingSeed := workingSeed * (-1);
    END_IF;
    IF workingSeed = 0 THEN
        workingSeed := 1;
    END_IF;
    
    (* Generate random number within specified range *)
    rangeSize := maxValue - minValue + 1;
    rawRandom := MOD(workingSeed, 32749);
    scaledRandom := MOD(rawRandom, rangeSize);
    randomNumber := minValue + scaledRandom;
    
    (* Set success status *)
    error := FALSE;
    status := 16#0000;
END_FUNCTION_BLOCK