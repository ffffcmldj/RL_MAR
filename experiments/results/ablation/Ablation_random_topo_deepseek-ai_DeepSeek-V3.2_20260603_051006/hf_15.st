FUNCTION_BLOCK FB_MergeBytes
VAR_INPUT
    byteArray : ARRAY[1..20] OF DINT; (* Byte array to be merged *)
END_VAR
VAR_OUTPUT
    dwordArray : ARRAY[1..10] OF DINT; (* Merged double word array *)
    mergeDwordNum : DINT; (* Actual number of merged double words *)
END_VAR
VAR
    i, j, k : DINT; (* Changed from INT to DINT to match array indices *)
    tempDword : DINT;
    currentByteValue : DINT;
END_VAR
VAR CONSTANT
    BYTE_ARRAY_SIZE : DINT := 20; (* Size of the input byte array *)
    DWORD_ARRAY_SIZE : DINT := 10; (* Size of the output DINT array *)
END_VAR

(* Main logic for merging bytes into double words *)
mergeDwordNum := 0;
tempDword := 0;

(* Calculate maximum possible double words from byte array *)
IF BYTE_ARRAY_SIZE >= 4 THEN
    FOR i := 1 TO BYTE_ARRAY_SIZE DO
        (* Extract current byte value (mask to keep only lowest 8 bits) *)
        currentByteValue := byteArray[i] AND 16#FF;
        
        (* Position byte within double word *)
        CASE (i MOD 4) OF
            1: (* First byte - least significant *)
                tempDword := currentByteValue;
                
            2: (* Second byte *)
                tempDword := tempDword OR (currentByteValue SHL 8);
                
            3: (* Third byte *)
                tempDword := tempDword OR (currentByteValue SHL 16);
                
            0: (* Fourth byte - most significant *)
                tempDword := tempDword OR (currentByteValue SHL 24);
                
                (* Store completed double word if space available *)
                IF mergeDwordNum < DWORD_ARRAY_SIZE THEN
                    mergeDwordNum := mergeDwordNum + 1;
                    dwordArray[mergeDwordNum] := tempDword;
                END_IF;
                
                tempDword := 0; (* Reset for next double word *)
        END_CASE;
    END_FOR;
END_IF;

(* Clear remaining positions in dwordArray if any *)
FOR k := (mergeDwordNum + 1) TO DWORD_ARRAY_SIZE DO
    dwordArray[k] := 0;
END_FOR;

END_FUNCTION_BLOCK