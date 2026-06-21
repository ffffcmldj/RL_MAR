FUNCTION_BLOCK FB_MergeBytes
VAR_INPUT
    byteArray : ARRAY[1..20] OF DINT; (* Byte array to be merged *)
END_VAR
VAR_OUTPUT
    dwordArray : ARRAY[1..10] OF DINT; (* Merged double word array *)
    mergeDwordNum : DINT; (* Actual number of merged double words *)
END_VAR
VAR
    i : DINT;
    j, k : INT;
    tempDword : DINT;
    currentByteValue : DINT;
    maxPossibleMerges : DINT;
    byteIndex : DINT;
    dwordIndex : INT;
END_VAR
VAR CONSTANT
    BYTE_ARRAY_SIZE : DINT := 20; (* Size of the input byte array *)
    DWORD_ARRAY_SIZE : DINT := 10; (* Size of the output DINT array *)
END_VAR

    (* Initialize output variables *)
    mergeDwordNum := 0;
    
    (* Calculate maximum possible merges based on input array size *)
    maxPossibleMerges := BYTE_ARRAY_SIZE / 4;
    
    (* Limit merges by output array capacity *)
    IF maxPossibleMerges > DWORD_ARRAY_SIZE THEN
        maxPossibleMerges := DWORD_ARRAY_SIZE;
    END_IF;
    
    (* Process each possible merge position *)
    FOR i := 1 TO maxPossibleMerges DO
        (* Reset temporary dword for this merge *)
        tempDword := 0;
        
        (* Calculate starting index in byte array for this group of 4 bytes *)
        byteIndex := (i - 1) * 4 + 1;
        
        (* Check if we have enough bytes in the array *)
        IF byteIndex + 3 <= BYTE_ARRAY_SIZE THEN
            (* Combine 4 bytes into one dword *)
            FOR j := 0 TO 3 DO
                (* Get current byte value *)
                currentByteValue := byteArray[byteIndex + j];
                
                (* Mask to ensure only lower 8 bits are used *)
                currentByteValue := currentByteValue AND 16#FF;
                
                (* Shift to appropriate position and combine *)
                IF j = 0 THEN
                    tempDword := currentByteValue * 256 * 256 * 256; (* Shift left 24 bits *)
                ELSIF j = 1 THEN
                    tempDword := tempDword OR (currentByteValue * 256 * 256); (* Shift left 16 bits *)
                ELSIF j = 2 THEN
                    tempDword := tempDword OR (currentByteValue * 256); (* Shift left 8 bits *)
                ELSE
                    tempDword := tempDword OR currentByteValue; (* No shift needed *)
                END_IF;
            END_FOR;
            
            (* Store the merged dword in output array *)
            dwordArray[i] := tempDword;
            
            (* Increment merge counter *)
            mergeDwordNum := mergeDwordNum + 1;
        ELSE
            (* Not enough bytes for a complete merge, stop processing *)
            EXIT;
        END_IF;
    END_FOR;
    
    (* Clear any remaining positions in output array if needed *)
    (* Note: According to requirements, we don't need to clear unused positions *)
    
END_FUNCTION_BLOCK