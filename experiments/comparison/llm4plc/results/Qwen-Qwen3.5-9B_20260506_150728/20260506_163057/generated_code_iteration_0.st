START_ST
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
    state : Int; // Current FSM State (0..5)
    dataLength : Int; // Temporary variable for dataInput[0]
    i : INT; // Loop counter for storage
END_VAR

END_VAR

// --- STATE MACHINE LOGIC ---

CASE state OF
    0: // STATE 0: IDLE (Reset or No Trigger)
        error := FALSE;
        status := 0;
        // usedSpace and remainingSpace are retained here automatically
        // dataBase is retained here automatically

    1: // STATE 1: RESET_EXECUTION (Clearing DB and counters)
        FOR i := 1 TO 20 DO
            dataBase[i] := 0;
        END_FOR;
        usedSpace := 0;
        remainingSpace := 20;
        error := FALSE;
        status := 0;
        state := 0; // Transition to Idle

    2: // STATE 2: VALIDATION_LENGTH (Checking dataInput[0])
        dataLength := dataInput[0];
        IF dataLength <= 0 OR dataLength > 5 THEN
            error := TRUE;
            status := 16#8001;
            state := 5; // Transition to Error Handling
        ELSE
            state := 3; // Transition to Space Validation
        END_IF;

    3: // STATE 3: VALIDATION_SPACE (Checking available space)
        IF (usedSpace + dataLength) > 20 THEN
            error := TRUE;
            status := 16#8002;
            state := 5; // Transition to Error Handling
        ELSE
            state := 4; // Transition to Storage Execution
        END_IF;

    4: // STATE 4: STORAGE_EXECUTION (Writing data to dataBase)
        FOR i := 1 TO dataLength DO
            dataBase[usedSpace + i] := dataInput[i];
        END_FOR;
        usedSpace := usedSpace + dataLength;
        remainingSpace := 20 - usedSpace;
        error := FALSE;
        status := 0;
        state := 0; // Transition to Idle

    5: // STATE 5: ERROR_HANDLING (Setting error flags)
        // Error and Status are already set in transitions 2 and 3
        state := 0; // Transition to Idle
END_CASE

END_FUNCTION_BLOCK
END_ST