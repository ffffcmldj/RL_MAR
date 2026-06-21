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
END_VAR

BEGIN
    (* Step 1: Validate input range *)
    IF minValue > maxValue THEN
        error := TRUE;
        status := 16#8200;
        randomNumber := 0;
        RETURN;
    END_IF;
    
    (* Step 2: Set success status *)
    error := FALSE;
    status := 16#0000;
    
    (* Step 3: Ensure seed is positive *)
    IF randomSeed_in < 0 THEN
        workingSeed := -randomSeed_in;
    ELSE
        workingSeed := randomSeed_in;
    END_IF;
    
    (* Step 4: Calculate inclusive range size *)
    rangeSize := maxValue - minValue + 1;
    
    (* Step 5: Generate pseudo-random value using linear congruential generator *)
    workingSeed := (workingSeed * 1103515245 + 12345) MOD 2147483647;
    
    (* Step 6: Scale to desired range *)
    randomNumber := minValue + (workingSeed MOD rangeSize);
END_FUNCTION_BLOCK;