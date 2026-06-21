FUNCTION_BLOCK FB_DatabaseManager
    VAR_INPUT
        dataInput : ARRAY[0..5] OF BYTE;
        storeTrigger : BOOL;
        resetTrigger : BOOL;
    END_VAR

    VAR_OUTPUT
        usedSpace : INT := 0;
        remainingSpace : INT := 20;
        error : BOOL := FALSE;
        status : WORD := 0;
    END_VAR

    VAR_IN_OUT
        dataBase : ARRAY[1..20] OF BYTE;
    END_VAR

    VAR
        index : INT;
        dataLength : INT;
        i : INT;
    END_VAR

    // Reset operation
    IF resetTrigger THEN
        FOR index := 1 TO 20 DO
            dataBase[index] := 0; // Clear database
        END_FOR
        usedSpace := 0; // Reset used space
        remainingSpace := 20; // Reset remaining space
        error := FALSE; // Clear error
        status := 0; // Clear status
    END_IF

    // Data storage operation
    IF storeTrigger THEN
        dataLength := dataInput[0]; // Read length from input

        // Length validation
        IF (dataLength <= 0) OR (dataLength > 5) THEN
            error := TRUE;
            status := 16#8001; // Invalid data length error
        ELSE
            // Space verification
            IF (usedSpace + dataLength) > 20 THEN
                error := TRUE;
                status := 16#8002; // Insufficient space error
            ELSE
                // Data storage
                FOR i := 1 TO dataLength DO
                    dataBase[usedSpace + i] := dataInput[i]; // Store data
                END_FOR
                usedSpace := usedSpace + dataLength; // Update used space
                remainingSpace := 20 - usedSpace; // Update remaining space
                error := FALSE; // Clear error
                status := 0; // Operation successful
            END_IF
        END_IF
    END_IF
END_FUNCTION_BLOCK