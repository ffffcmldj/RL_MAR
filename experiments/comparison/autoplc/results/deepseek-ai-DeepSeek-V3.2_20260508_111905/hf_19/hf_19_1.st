FUNCTION_BLOCK FB_DatabaseManager
VAR_INPUT
    dataInput : ARRAY[0..5] OF BYTE;
    storeTrigger : BOOL;
    resetTrigger : BOOL;
END_VAR

VAR_OUTPUT
    usedSpace : INT := 0;
    remainingSpace : INT := 20;
    error : BOOL;
    status : WORD;
END_VAR

VAR_IN_OUT
    dataBase : ARRAY[1..20] OF BYTE;
END_VAR

VAR
    dataLength : INT;
    i : INT;
END_VAR

    // Reset operation has highest priority
    IF resetTrigger THEN
        // Clear database array
        FOR i := 1 TO 20 DO
            dataBase[i] := 0;
        END_FOR;
        
        // Reset counters
        usedSpace := 0;
        remainingSpace := 20;
        
        // Clear status
        error := FALSE;
        status := 0;
        
    // Store operation when reset is not active
    ELSIF storeTrigger THEN
        // Read data length from first byte
        dataLength := dataInput[0];
        
        // Length validation
        IF (dataLength <= 0) OR (dataLength > 5) THEN
            error := TRUE;
            status := 16#8001;
            
        // Space verification
        ELSIF (usedSpace + dataLength) > 20 THEN
            error := TRUE;
            status := 16#8002;
            
        // Data storage
        ELSE
            // Copy data bytes to database
            FOR i := 1 TO dataLength DO
                dataBase[usedSpace + i] := dataInput[i];
            END_FOR;
            
            // Update counters
            usedSpace := usedSpace + dataLength;
            remainingSpace := 20 - usedSpace;
            
            // Set success status
            error := FALSE;
            status := 0;
        END_IF;
    END_IF;

END_FUNCTION_BLOCK