FUNCTION_BLOCK FB_MergeBytes
VAR_INPUT
    byteArray : ARRAY[1..20] OF DINT; (* Byte array to be merged *)
END_VAR

VAR_OUTPUT
    dwordArray : ARRAY[1..10] OF DINT; (* Merged double word array *)
    mergeDwordNum : DINT; (* Actual number of merged double words *)
END_VAR

VAR
    i : DINT; (* Input byte index *)
    j : DINT; (* Byte counter within group (0-3) *)
    k : DINT; (* Output array index *)
    tempDword : DINT; (* Temporary storage for building double word *)
    currentByteValue : DINT; (* Temporary storage for current byte *)
END_VAR

VAR CONSTANT
    BYTE_ARRAY_SIZE : DINT := 20; (* Size of the input byte array *)
    DWORD_ARRAY_SIZE : DINT := 10; (* Size of the output DINT array *)
END_VAR

(* Initialize output count *)
mergeDwordNum := 0;

(* Clear output array *)
FOR k := 1 TO DWORD_ARRAY_SIZE DO
    dwordArray[k] := 0;
END_FOR;

(* Main merging loop *)
i := 1;
WHILE i <= BYTE_ARRAY_SIZE DO
    tempDword := 0;
    j := 0;
    
    (* Collect up to 4 bytes *)
    WHILE (j < 4) AND ((i + j) <= BYTE_ARRAY_SIZE) DO
        currentByteValue := byteArray[i + j];
        currentByteValue := currentByteValue AND 16#FF; (* Mask to keep only LSB *)
        tempDword := tempDword OR SHL(currentByteValue, 8 * j); (* Shift and combine *)
        j := j + 1;
    END_WHILE;
    
    (* Check if we have a complete group of 4 bytes *)
    IF j = 4 THEN
        k := mergeDwordNum + 1;
        
        (* Check if output array has space *)
        IF k <= DWORD_ARRAY_SIZE THEN
            dwordArray[k] := tempDword;
            mergeDwordNum := k;
        ELSE
            EXIT; (* Output array full *)
        END_IF;
    ELSE
        EXIT; (* Incomplete byte group *)
    END_IF;
    
    i := i + 4; (* Move to next group *)
END_WHILE;

END_FUNCTION_BLOCK;