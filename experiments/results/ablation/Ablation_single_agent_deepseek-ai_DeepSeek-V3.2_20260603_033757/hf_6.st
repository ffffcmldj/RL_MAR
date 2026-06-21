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
    internalSeed : DINT;
END_VAR

(* Check for invalid range *)
IF minValue > maxValue THEN
    error := TRUE;
    status := 16#8200;
    randomNumber := 0;
ELSE
    (* Initialize with external seed *)
    internalSeed := randomSeed_in;
    
    (* Ensure seed is positive *)
    IF internalSeed < 0 THEN
        internalSeed := -internalSeed;
    END_IF;
    
    (* Simple linear congruential generator algorithm *)
    internalSeed := internalSeed * 1103515245 + 12345;
    
    (* Generate random number within specified range *)
    randomNumber := minValue + (internalSeed MOD (maxValue - minValue + 1));
    
    (* Set success status *)
    error := FALSE;
    status := 16#0000;
END_IF;