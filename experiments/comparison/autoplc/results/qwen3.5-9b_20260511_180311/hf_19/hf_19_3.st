FUNCTION_BLOCK FB_DatabaseManager
VAR_INPUT
    dataInput : Array[0..5] of Byte;
    storeTrigger : Bool;
    resetTrigger : Bool;
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
    index : INT;
    dataLength : INT;
    i : INT;
END_VAR;

    error := FALSE;
    status := 0;

    IF resetTrigger THEN
        FOR index := 1 TO 20 DO
            dataBase[index] := 0;
        END_FOR;
        usedSpace := 0;
        remainingSpace := 20;
        error := FALSE;
        status := 0;
    ELSIF storeTrigger THEN
        dataLength := Int(dataInput[0]);
        IF (dataLength <= 0) OR (dataLength > 5) THEN
            error := TRUE;
            status := 16#8001;
        ELSIF (usedSpace + dataLength) > 20 THEN
            error := TRUE;
            status := 16#8002;
        ELSE
            FOR i := 1 TO dataLength DO
                dataBase[usedSpace + i] := Byte(dataInput[i]);
            END_FOR;
            usedSpace := usedSpace + dataLength;
            remainingSpace := 20 - usedSpace;
            error := FALSE;
            status := 0;
        END_IF;
    END_IF;

END_FUNCTION_BLOCK