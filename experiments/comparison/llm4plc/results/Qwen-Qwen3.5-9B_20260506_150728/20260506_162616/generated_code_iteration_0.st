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
    k : INT; (* Loop counter for double words *)
    b1, b2, b3, b4 : DINT; (* Temporary byte holders *)
    tempDword : DINT; (* Accumulated result *)
    maxMerges : DINT; (* Potential merges based on input size *)
    limit : DINT; (* Actual merges based on input and output size *)
    BYTE_ARRAY_SIZE : DINT := 20;
    DWORD_ARRAY_SIZE : DINT := 10;
END_VAR
VAR CONSTANT
    SHIFT_8 : DINT := 256;
    SHIFT_16 : DINT := 65536;
    SHIFT_24 : DINT := 16777216;
END_VAR

BEGIN
    (* STATE 0: INITIALIZE *)
    mergeDwordNum := 0;
    FOR i := 1 TO DWORD_ARRAY_SIZE DO
        dwordArray[i] := 0;
    END_FOR;

    (* STATE 1: CALCULATE LIMITS *)
    maxMerges := BYTE_ARRAY_SIZE DIV 4;
    IF maxMerges > DWORD_ARRAY_SIZE THEN
        limit := DWORD_ARRAY_SIZE;
    ELSE
        limit := maxMerges;
    END_IF;

    (* STATE 2: MERGE AND STORE LOOP *)
    FOR k := 0 TO limit - 1 DO
        (* Check if 4 bytes exist at index k*4 *)
        IF (k * 4 + 4) <= BYTE_ARRAY_SIZE THEN
            (* Extract 4 bytes: byteArray[k*4+1] to byteArray[k*4+4] *)
            b1 := byteArray[(k * 4) + 1];
            b2 := byteArray[(k * 4) + 2];
            b3 := byteArray[(k * 4) + 3];
            b4 := byteArray[(k * 4) + 4];

            (* Construct tempDword (Little Endian: Byte1=LSB, Byte4=MSB) *)
            tempDword := b1 + (b2 * SHIFT_8) + (b3 * SHIFT_16) + (b4 * SHIFT_24);

            (* Store result *)
            dwordArray[k + 1] := tempDword;

            (* Increment counter *)
            mergeDwordNum := mergeDwordNum + 1;
        ELSE
            (* Insufficient bytes, exit loop *)
            EXIT;
        END_IF;
    END_FOR;

    (* STATE 3: FINALIZE - Counter already updated inside loop *)
END_FUNCTION_BLOCK
END_ST