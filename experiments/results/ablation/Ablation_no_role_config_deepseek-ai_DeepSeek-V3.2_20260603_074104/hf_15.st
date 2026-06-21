FUNCTION_BLOCK FB_MergeBytes
VAR_INPUT
    byteArray : ARRAY[1..20] OF DINT; (* Byte array to be merged *)
END_VAR
VAR_OUTPUT
    dwordArray : ARRAY[1..10] OF DINT; (* Merged double word array *)
    mergeDwordNum : DINT; (* Actual number of merged double words *)
END_VAR
VAR
    i, j : INT;
    tempDword : DINT;
    byteIndex : INT;
    dwordIndex : INT;
    maxDwords : INT;
END_VAR
VAR CONSTANT
    BYTE_ARRAY_SIZE : DINT := 20; (* Size of the input byte array *)
    DWORD_ARRAY_SIZE : DINT := 10; (* Size of the output DINT array *)
END_VAR

(* Clear output array *)
FOR i := 1 TO DWORD_ARRAY_SIZE DO
    dwordArray[i] := 0;
END_FOR;

mergeDwordNum := 0;

(* Calculate maximum number of complete 4-byte groups in byteArray *)
maxDwords := BYTE_ARRAY_SIZE / 4; (* Integer division automatically truncates remainder *)

(* Limit by dwordArray capacity *)
IF maxDwords > DWORD_ARRAY_SIZE THEN
    maxDwords := DWORD_ARRAY_SIZE;
END_IF;

(* Merge bytes into double words *)
FOR dwordIndex := 1 TO maxDwords DO
    tempDword := 0;
    byteIndex := (dwordIndex - 1) * 4 + 1;
    
    (* Merge 4 bytes into one double word *)
    FOR j := 0 TO 3 DO
        (* Shift left and OR with current byte *)
        tempDword := tempDword * 256; (* Equivalent to SHL 8 *)
        tempDword := tempDword OR byteArray[byteIndex + j];
    END_FOR;
    
    dwordArray[dwordIndex] := tempDword;
    mergeDwordNum := mergeDwordNum + 1;
END_FOR;

END_FUNCTION_BLOCK