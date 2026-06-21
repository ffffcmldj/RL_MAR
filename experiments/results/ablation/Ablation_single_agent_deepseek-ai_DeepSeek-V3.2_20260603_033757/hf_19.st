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
    i : INT;
    dataLength : INT;
END_VAR

// Main execution logic
IF resetTrigger THEN
    // Reset operation
    FOR i := 1 TO 20 DO
        dataBase[i] := 0;
    END_FOR;
    usedSpace := 0;
    remainingSpace := 20;
    error := FALSE;
    status := 0;
ELSIF storeTrigger THEN
    // Data storage operation
    dataLength := dataInput[0];
    
    // Length validation
    IF (dataLength <= 0) OR (dataLength > 5) THEN
        error := TRUE;
        status := 16#8001;
    ELSE
        // Space verification
        IF (usedSpace + dataLength) > 20 THEN
            error := TRUE;
            status := 16#8002;
        ELSE
            // Data storage
            FOR i := 1 TO dataLength DO
                dataBase[usedSpace + i] := dataInput[i];
            END_FOR;
            
            // Update counters and status
            usedSpace := usedSpace + dataLength;
            remainingSpace := 20 - usedSpace;
            error := FALSE;
            status := 0;
        END_IF;
    END_IF;
END_IF;

END_FUNCTION_BLOCK