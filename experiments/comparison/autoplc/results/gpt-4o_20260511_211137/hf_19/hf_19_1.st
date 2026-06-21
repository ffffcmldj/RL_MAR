FUNCTION_BLOCK FB_DatabaseManager
    VAR_INPUT 
        dataInput : Array[0..5] of Byte;
        storeTrigger : Bool;
        resetTrigger : Bool;
    END_VAR

    VAR_OUTPUT 
        usedSpace : Int := 0;
        remainingSpace : Int := 20;
        error : Bool;
        status : Word;
    END_VAR

    VAR_IN_OUT 
        dataBase : Array[1..20] of Byte;
    END_VAR

    VAR
        index : Int;
        dataLength : Int;
        i : INT;
    END_VAR

    // Main execution block
    IF resetTrigger THEN
        // Reset Operation
        FOR index := 1 TO 20 DO
            dataBase[index] := 0;
        END_FOR
        usedSpace := 0;
        remainingSpace := 20;
        error := FALSE;
        status := 0;
    ELSIF storeTrigger THEN
        // Data Storage Operation
        dataLength := dataInput[0];

        // Length Validation
        IF (dataLength <= 0) OR (dataLength > 5) THEN
            error := TRUE;
            status := 16#8001;
        ELSE
            // Space Verification
            IF (usedSpace + dataLength) > 20 THEN
                error := TRUE;
                status := 16#8002;
            ELSE
                // Data Storage
                FOR i := 1 TO dataLength DO
                    dataBase[usedSpace + i] := dataInput[i];
                END_FOR
                usedSpace := usedSpace + dataLength;
                remainingSpace := 20 - usedSpace;
                error := FALSE;
                status := 0;
            END_IF
        END_IF
    END_IF
END_FUNCTION_BLOCK