FUNCTION_BLOCK FB_MergeBytes
    VAR_INPUT
        byteArray : ARRAY[1..20] OF DINT; (* Byte array to be merged *)
    END_VAR
    VAR_OUTPUT
        dwordArray : ARRAY[1..10] OF DINT; (* Merged double word array *)
        mergeDwordNum : DINT; (* Actual number of merged double words *)
    END_VAR
    VAR
        i, j : INT; (* Loop control variables *)
        tempDword : DINT; (* Temporary variable for merged double word *)
    END_VAR
    VAR CONSTANT
        BYTE_ARRAY_SIZE : DINT := 20; (* Size of the input byte array *)
        DWORD_ARRAY_SIZE : DINT := 10; (* Size of the output DINT array *)
    END_VAR

    // Initialize the output variable
    mergeDwordNum := 0;
    
    // Calculate the maximum number of double words that can be formed
    FOR i := 1 TO BYTE_ARRAY_SIZE BY 4 DO
        IF mergeDwordNum < DWORD_ARRAY_SIZE THEN
            // Merge 4 bytes into a double word
            tempDword := 0; // Reset tempDword for each new double word
            FOR j := 0 TO 3 DO
                // Check if we are within the bounds of byteArray
                IF (i + j) <= BYTE_ARRAY_SIZE THEN
                    tempDword := tempDword OR (byteArray[i + j] * (16#1000000 >> (8 * j))); // Shift and merge using multiplication and right shift
                END_IF
            END_FOR
            
            // Store the merged double word in dwordArray
            dwordArray[mergeDwordNum + 1] := tempDword; // Store at the current index
            mergeDwordNum := mergeDwordNum + 1; // Increment the count of merged double words
        END_IF
    END_FOR
END_FUNCTION_BLOCK