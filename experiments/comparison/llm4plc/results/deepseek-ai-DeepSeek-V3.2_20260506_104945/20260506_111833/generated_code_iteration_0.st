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
    i : DINT; (* Index for byteArray, steps of 4 *)
    j : DINT; (* Index for dwordArray *)
    byteIndex : DINT; (* Index within a group of 4 bytes *)
    tempDword : DINT; (* Temporary storage for building a DWORD *)
    currentByte : DINT; (* Current byte value for processing *)
    maxByteGroups : DINT; (* Maximum number of complete 4-byte groups in byteArray *)
    maxDwordCapacity : DINT; (* Maximum number of DWORDs that can be stored in dwordArray *)
    groupsToProcess : DINT; (* Actual number of groups to process *)
END_VAR
VAR CONSTANT
    BYTE_ARRAY_SIZE : DINT := 20; (* Size of the input byte array *)
    DWORD_ARRAY_SIZE : DINT := 10; (* Size of the output DINT array *)
    BYTES_PER_DWORD : DINT := 4; (* Number of bytes per DWORD *)
END_VAR

    (* Initialize output *)
    mergeDwordNum := 0;
    FOR j := 1 TO DWORD_ARRAY_SIZE DO
        dwordArray[j] := 0;
    END_FOR;

    (* Calculate maximum number of complete 4-byte groups in the byteArray *)
    maxByteGroups := BYTE_ARRAY_SIZE / BYTES_PER_DWORD; (* Integer division, truncates remainder *)

    (* The number of DWORDs we can store is limited by dwordArray size *)
    maxDwordCapacity := DWORD_ARRAY_SIZE;

    (* Determine how many groups we can actually process *)
    IF maxByteGroups < maxDwordCapacity THEN
        groupsToProcess := maxByteGroups;
    ELSE
        groupsToProcess := maxDwordCapacity;
    END_IF;

    (* Main merging loop: process each group of 4 bytes *)
    FOR i := 0 TO groupsToProcess-1 DO
        tempDword := 0; (* Reset temporary DWORD for new group *)

        (* Inner loop: combine 4 bytes into one DWORD *)
        FOR byteIndex := 0 TO BYTES_PER_DWORD-1 DO
            (* Calculate index in byteArray (1-based) *)
            currentByte := byteArray[i * BYTES_PER_DWORD + byteIndex + 1];

            (* Merge byte into the appropriate position in tempDword *)
            (* Assuming byte order: first byte is most significant (b1 << 24) *)
            tempDword := tempDword OR (SHL(currentByte AND 16#FF, (BYTES_PER_DWORD - 1 - byteIndex) * 8));
        END_FOR;

        (* Store the merged DWORD in the output array *)
        dwordArray[i + 1] := tempDword;

        (* Increment the count of successfully merged DWORDs *)
        mergeDwordNum := mergeDwordNum + 1;
    END_FOR;

END_FUNCTION_BLOCK
END_ST