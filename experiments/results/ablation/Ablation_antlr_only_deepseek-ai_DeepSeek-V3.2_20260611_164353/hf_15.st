FUNCTION_BLOCK FB_MergeBytes
VAR_INPUT
    byteArray : ARRAY[1..20] OF DINT; (* Each DINT element holds one byte value (0-255) *)
END_VAR
VAR_OUTPUT
    dwordArray : ARRAY[1..10] OF DINT; (* Each DINT will hold 4 merged bytes *)
    mergeDwordNum : DINT; (* Actual number of successfully merged double words *)
END_VAR
VAR
    iByteIndex : DINT; (* Index for traversing byteArray *)
    iDwordIndex : DINT; (* Index for traversing dwordArray *)
    iByteInGroup : DINT; (* Index within a 4-byte group (0-3) *)
    tempDword : DINT; (* Temporary storage for building the double word *)
    currentByte : DINT; (* Temporary storage for a single byte value *)
END_VAR
VAR CONSTANT
    BYTE_ARRAY_SIZE : DINT := 20;
    DWORD_ARRAY_SIZE : DINT := 10;
    BYTES_PER_DWORD : DINT := 4;
END_VAR

(* Initialize output count *)
mergeDwordNum := 0;

(* Clear the output array to ensure predictable state *)
FOR iDwordIndex := 1 TO DWORD_ARRAY_SIZE DO
    dwordArray[iDwordIndex] := 0;
END_FOR;

(* Main merging loop *)
iByteIndex := 1;
iDwordIndex := 1;

WHILE (iByteIndex + (BYTES_PER_DWORD - 1) <= BYTE_ARRAY_SIZE) AND (iDwordIndex <= DWORD_ARRAY_SIZE) DO
    (* Initialize the temporary double word for this group *)
    tempDword := 0;
    
    (* Combine 4 consecutive bytes into one double word *)
    FOR iByteInGroup := 0 TO BYTES_PER_DWORD-1 DO
        (* Extract the lowest 8 bits (one byte) from the DINT element *)
        currentByte := byteArray[iByteIndex + iByteInGroup] AND 16#000000FF;
        
        (* Shift the byte to its correct position and OR it into the temporary double word *)
        tempDword := tempDword OR SHL(currentByte, iByteInGroup * 8);
    END_FOR;
    
    (* Store the merged double word and update counters *)
    dwordArray[iDwordIndex] := tempDword;
    mergeDwordNum := mergeDwordNum + 1;
    
    (* Move to the next group of bytes and the next double word slot *)
    iByteIndex := iByteIndex + BYTES_PER_DWORD;
    iDwordIndex := iDwordIndex + 1;
END_WHILE;

END_FUNCTION_BLOCK;