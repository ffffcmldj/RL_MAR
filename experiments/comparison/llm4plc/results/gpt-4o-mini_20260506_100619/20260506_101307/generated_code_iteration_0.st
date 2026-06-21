ructured-text
START_ST
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
    state : INT; // THE STATE VARIABLE
    prevState : INT; // THE PREVIOUS STATE VARIABLE
    dataLength : INT; // THE LENGTH OF DATA TO STORE
    i : INT; // LOOP INDEX
END_VAR

// STATE MACHINE IMPLEMENTATION
state := 0; // INITIAL STATE

IF resetTrigger THEN
    state := 1; // GO TO RESET DATABASE STATE
ELSIF storeTrigger AND NOT resetTrigger THEN
    state := 2; // GO TO VALIDATE DATA LENGTH STATE
END_IF

CASE state OF
    0: // INITIALIZE
        usedSpace := 0;
        remainingSpace := 20;
        error := FALSE;
        status := 0;

    1: // RESET DATABASE
        FOR i := 1 TO 20 DO
            dataBase[i] := 0;
        END_FOR
        usedSpace := 0;
        remainingSpace := 20;
        error := FALSE;
        status := 0;
        state := 0; // RETURN TO INITIAL STATE AFTER RESET

    2: // VALIDATE DATA LENGTH
        dataLength := dataInput[0];
        IF dataLength <= 0 OR dataLength > 5 THEN
            error := TRUE;
            status := 16#8001; // INVALID DATA LENGTH ERROR
            state := 5; // GO TO OPERATION SUCCESS STATE
        ELSE
            state := 3; // GO TO VERIFY SPACE STATE
        END_IF

    3: // VERIFY SPACE
        IF (usedSpace + dataLength) > 20 THEN
            error := TRUE;
            status := 16#8002; // INSUFFICIENT SPACE ERROR
            state := 5; // GO TO OPERATION SUCCESS STATE
        ELSE
            state := 4; // GO TO STORE DATA STATE
        END_IF

    4: // STORE DATA
        FOR i := 1 TO dataLength DO
            dataBase[usedSpace + i] := dataInput[i];
        END_FOR
        usedSpace := usedSpace + dataLength;
        remainingSpace := 20 - usedSpace;
        error := FALSE;
        status := 0;
        state := 5; // GO TO OPERATION SUCCESS STATE

    5: // OPERATION SUCCESS
        // No changes to outputs
        state := 0; // RETURN TO INITIAL STATE AFTER OPERATION COMPLETED

END_CASE

END_FUNCTION_BLOCK
END_ST