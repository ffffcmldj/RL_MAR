FUNCTION_BLOCK FB_MergeBytes
VAR_INPUT
    byteArray : ARRAY[1..20] OF DINT; (* Byte array to be merged *)
END_VAR
VAR_OUTPUT
    dwordArray : ARRAY[1..10] OF DINT; (* Merged double word array *)
    mergeDwordNum : DINT; (* Actual number of merged double words *)
END_VAR
VAR
    i : INT; (* Loop counter for dwordArray clearing *)
    j : INT; (* Loop counter for byte processing within a dword *)
    dwordIdx : INT; (* Current position in dwordArray *)
    byteIdx : INT; (* Current position in byteArray *)
    maxDwordCount : INT; (* Maximum number of dwords that can be processed *)
    tempDword : DINT; (* Temporary storage for building dword *)
    currentByteValue : DINT; (* Temporary storage for byte value *)
END_VAR
VAR CONSTANT
    BYTE_ARRAY_SIZE : DINT := 20; (* Size of the input byte array *)
    DWORD_ARRAY_SIZE : DINT := 10; (* Size of the output DINT array *)
END_VAR

(* Initialize output array and counter *)
FOR i := 1 TO DWORD_ARRAY_SIZE DO
    dwordArray[i] := 0;
END_FOR;
mergeDwordNum := 0;

(* Calculate maximum number of complete 4-byte chunks available *)
maxDwordCount := BYTE_ARRAY_SIZE / 4; (* Integer division truncates remainder *)

(* Limit processing by output array capacity *)
IF maxDwordCount > DWORD_ARRAY_SIZE THEN
    maxDwordCount := DWORD_ARRAY_SIZE;
END_IF;

(* Process each complete 4-byte chunk *)
dwordIdx := 1;
byteIdx := 1;
WHILE (dwordIdx <= maxDwordCount) DO
    tempDword := 0;
    
    (* Merge 4 bytes into one double word *)
    FOR j := 0 TO 3 DO
        currentByteValue := byteArray[byteIdx + j];
        
        (* Ensure byte value is in valid range (0-255) *)
        IF currentByteValue < 0 THEN
            currentByteValue := currentByteValue AND 16#000000FF;
        ELSIF currentByteValue > 255 THEN
            currentByteValue := currentByteValue AND 16#000000FF;
        END_IF;
        
        (* Shift byte into position and combine *)
        tempDword := tempDword OR SHL(currentByteValue, (j * 8));
    END_FOR;
    
    (* Store the merged double word *)
    dwordArray[dwordIdx] := tempDword;
    
    (* Update counters *)
    mergeDwordNum := mergeDwordNum + 1;
    dwordIdx := dwordIdx + 1;
    byteIdx := byteIdx + 4;
END_WHILE;

END_FUNCTION_BLOCK;