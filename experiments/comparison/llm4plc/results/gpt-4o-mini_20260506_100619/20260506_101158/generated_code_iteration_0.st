ructured-text
FUNCTION_BLOCK FB_MergeBytes
VAR_INPUT
    byteArray : ARRAY[1..20] OF DINT; (* Byte array to be merged *)
END_VAR
VAR_OUTPUT
    dwordArray : ARRAY[1..10] OF DINT; (* Merged double word array *)
    mergeDwordNum : DINT; (* Actual number of merged double words *)
END_VAR
VAR
    i, j, k : INT; (* Index variables *)
    tempDword : DINT; (* Temporary variable to hold merged double word *)
END_VAR
VAR CONSTANT
    BYTE_ARRAY_SIZE : DINT := 20; (* Size of the input byte array *)
    DWORD_ARRAY_SIZE : DINT := 10; (* Size of the output DINT array *)
END_VAR

(* Initialize state variables *)
i := 1;
j := 1;
k := 0;
mergeDwordNum := 0;

(* Initialize dwordArray to zero *)
FOR j := 1 TO DWORD_ARRAY_SIZE DO
    dwordArray[j] := 0;
END_FOR

(* Merging bytes into double words *)
WHILE (i <= BYTE_ARRAY_SIZE) AND (j <= DWORD_ARRAY_SIZE) DO
    IF (i + 3 <= BYTE_ARRAY_SIZE) THEN
        tempDword := byteArray[i] + (byteArray[i + 1] << 8) + (byteArray[i + 2] << 16) + (byteArray[i + 3] << 24);
        dwordArray[j] := tempDword;
        mergeDwordNum := mergeDwordNum + 1;
        j := j + 1;
        i := i + 4;
    ELSE
        EXIT; (* Exit loop if not enough bytes left to merge *)
    END_IF
END_WHILE

END_FUNCTION_BLOCK