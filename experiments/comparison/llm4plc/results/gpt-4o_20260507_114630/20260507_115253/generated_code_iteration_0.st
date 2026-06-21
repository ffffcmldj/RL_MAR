pascal
START_ST
FUNCTION_BLOCK FB_MergeBytes
VAR_INPUT
    byteArray : ARRAY[1..20] OF DINT; (* Byte array to be merged *)
END_VAR
VAR_OUTPUT
    dwordArray : ARRAY[1..10] OF DINT; (* Merged double word array *)
    mergeDwordNum : DINT; (* Actual number of merged double words *)
END_VAR
VAR
    i : INT; (* Index for iterating through byteArray *)
    j : INT; (* Index for iterating through dwordArray *)
    k : INT; (* Counter for tracking bytes merged into a single double word *)
    tempDword : DINT; (* Temporary variable to store the current double word being formed *)
    currentByteValue : DINT; (* Temporary variable to hold the value of the current byte being processed *)
END_VAR
VAR CONSTANT
    BYTE_ARRAY_SIZE : DINT := 20; (* Size of the input byte array *)
    DWORD_ARRAY_SIZE : DINT := 10; (* Size of the output DINT array *)
END_VAR

(* STATE 0: INITIALIZE *)
mergeDwordNum := 0; (* Reset the number of merged double words *)
i := 1; (* Start index for byteArray *)
j := 1; (* Start index for dwordArray *)
k := 0; (* Reset the byte counter for forming a double word *)
tempDword := 0; (* Reset the temporary double word storage *)
currentByteValue := 0; (* Reset the current byte value *)

(* STATE 1: MERGE BYTES INTO DOUBLE WORDS *)
WHILE (i <= BYTE_ARRAY_SIZE) AND (j <= DWORD_ARRAY_SIZE) DO
    (* Get the current byte value from byteArray *)
    currentByteValue := byteArray[i];
    
    (* Merge the current byte into the temporary double word *)
    tempDword := tempDword OR (currentByteValue SHL (k * 8));
    
    (* Increment the byte counter *)
    k := k + 1;

    (* Check if 4 bytes have been merged into a double word *)
    IF k = 4 THEN
        (* Store the completed double word into dwordArray *)
        dwordArray[j] := tempDword;
        
        (* Increment the number of merged double words *)
        mergeDwordNum := mergeDwordNum + 1;
        
        (* Move to the next index in dwordArray *)
        j := j + 1;
        
        (* Reset the byte counter and temporary double word storage *)
        k := 0;
        tempDword := 0;
    END_IF;

    (* Move to the next byte in byteArray *)
    i := i + 1;
END_WHILE;

(* STATE 2: FINALIZE OUTPUT *)
(* No further processing is required in this state. *)

END_FUNCTION_BLOCK
END_ST