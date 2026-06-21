FUNCTION_BLOCK FB_MergeBytes
VAR_INPUT
    byteArray : ARRAY[1..20] OF DINT; (* Byte array to be merged *)
END_VAR
VAR_OUTPUT
    dwordArray : ARRAY[1..10] OF DINT; (* Merged double word array *)
    mergeDwordNum : DINT;
END_VAR
VAR
    i, j : DINT;
    tempDword : DWORD;
    bytePos : DINT;
    dwordPos : DINT;
    maxDwords : DINT;
END_VAR
VAR CONSTANT
    BYTE_ARRAY_SIZE : DINT := 20; (* Size of the input byte array *)
    DWORD_ARRAY_SIZE : DINT := 10; (* Size of the output DINT array *)
END_VAR

BEGIN
    mergeDwordNum := 0;
    
    (* Clear output array *)
    FOR i := 1 TO DWORD_ARRAY_SIZE DO
        dwordArray[i] := 0;
    END_FOR;
    
    (* Calculate maximum number of DWORDs we can merge *)
    maxDwords := MIN(BYTE_ARRAY_SIZE / 4, DWORD_ARRAY_SIZE);
    
    (* Merge bytes into DWORDs *)
    FOR dwordPos := 0 TO maxDwords - 1 DO
        tempDword := 0;
        bytePos := dwordPos * 4;
        
        (* Check if we have enough bytes remaining *)
        IF (bytePos + 4) <= BYTE_ARRAY_SIZE THEN
            (* Merge 4 bytes into 1 DWORD *)
            FOR j := 0 TO 3 DO
                (* Shift each byte into position and combine *)
                tempDword := tempDword OR (SHL(TO_DWORD(byteArray[bytePos + j + 1] AND 16#FF), (3 - j) * 8));
            END_FOR;
            
            (* Store the merged DWORD *)
            dwordArray[dwordPos + 1] := TO_DINT(tempDword);
            mergeDwordNum := mergeDwordNum + 1;
        END_IF;
    END_FOR;
    
END_FUNCTION_BLOCK