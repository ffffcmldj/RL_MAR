FUNCTION_BLOCK FB_MergeBytes
    VAR_INPUT
        byteArray : ARRAY[1..20] OF BYTE; (* Byte array to be merged *)
    END_VAR
    VAR_OUTPUT
        dwordArray : ARRAY[1..10] OF DINT; (* Merged double word array *)
        mergeDwordNum : DINT; (* Actual number of merged double words *)
    END_VAR
    VAR
        i, j, k : INT; (* Loop variables *)
        tempDword : DINT; (* Temporary variable to store merged double word *)
        currentByteValue : BYTE; (* Temporary variable to store current byte value *)
    END_VAR
    VAR CONSTANT
        BYTE_ARRAY_SIZE : DINT := 20; (* Size of the input byte array *)
        DWORD_ARRAY_SIZE : DINT := 10; (* Size of the output DINT array *)
    END_VAR

    (* Initialize the number of merged double words *)
    mergeDwordNum := 0;

    (* Iterate over byteArray in chunks of 4 bytes *)
    i := 1;
    j := 1;
    WHILE (i <= BYTE_ARRAY_SIZE - 3) AND (j <= DWORD_ARRAY_SIZE) DO
        (* Reset tempDword for new merge *)
        tempDword := 0;

        (* Merge 4 bytes into a double word *)
        FOR k := 0 TO 3 DO
            currentByteValue := byteArray[i + k];
            tempDword := tempDword OR (currentByteValue SHL (8 * k));
        END_FOR

        (* Store the merged double word in dwordArray *)
        dwordArray[j] := tempDword;

        (* Increment counters *)
        mergeDwordNum := mergeDwordNum + 1;
        i := i + 4;
        j := j + 1;
    END_WHILE
END_FUNCTION_BLOCK