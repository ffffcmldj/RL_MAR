pascal
START_ST

FUNCTION_BLOCK FB_DatabaseManager
VAR_INPUT
    dataInput : ARRAY[0..5] OF BYTE; // Input data buffer
    storeTrigger : BOOL;            // Triggers data storage operation
    resetTrigger : BOOL;            // Triggers database reset
END_VAR

VAR_OUTPUT
    usedSpace : INT := 0;           // Currently occupied bytes
    remainingSpace : INT := 20;     // Available bytes
    error : BOOL := FALSE;          // Error indicator
    status : WORD := 0;             // Operation status code
END_VAR

VAR_IN_OUT
    dataBase : ARRAY[1..20] OF BYTE; // Main storage array
END_VAR

VAR
    state : INT := 0;               // Current state of the FSM
    dataLength : INT := 0;          // Length of data to be stored
    i : INT := 0;                   // Loop index for storing data
    index : INT := 0;               // Tracks the last used position in the database
END_VAR

// State Machine Implementation
CASE state OF

    // STATE 0: IDLE
    0:
        IF resetTrigger THEN
            state := 1; // Transition to RESET DATABASE state
        ELSIF storeTrigger THEN
            state := 2; // Transition to VALIDATE DATA LENGTH state
        END_IF;

    // STATE 1: RESET DATABASE
    1:
        // Clear all elements in dataBase
        FOR i := 1 TO 20 DO
            dataBase[i] := 0;
        END_FOR;

        // Reset counters
        usedSpace := 0;
        remainingSpace := 20;

        // Clear error and status
        error := FALSE;
        status := 0;

        // Transition back to IDLE state
        state := 0;

    // STATE 2: VALIDATE DATA LENGTH
    2:
        // Read dataLength from dataInput[0]
        dataLength := dataInput[0];

        // Check if dataLength is valid
        IF (dataLength <= 0) OR (dataLength > 5) THEN
            error := TRUE;
            status := 16#8001; // Invalid data length error
            state := 0;        // Transition back to IDLE state
        ELSE
            error := FALSE;
            status := 0;
            state := 3;        // Transition to VERIFY AVAILABLE SPACE state
        END_IF;

    // STATE 3: VERIFY AVAILABLE SPACE
    3:
        // Check if there is enough space in the database
        IF (usedSpace + dataLength) > 20 THEN
            error := TRUE;
            status := 16#8002; // Insufficient space error
            state := 0;        // Transition back to IDLE state
        ELSE
            error := FALSE;
            status := 0;
            state := 4;        // Transition to STORE DATA state
        END_IF;

    // STATE 4: STORE DATA
    4:
        // Append data to dataBase
        FOR i := 1 TO dataLength DO
            dataBase[usedSpace + i] := dataInput[i];
        END_FOR;

        // Update usedSpace and remainingSpace
        usedSpace := usedSpace + dataLength;
        remainingSpace := 20 - usedSpace;

        // Clear error and set status to success
        error := FALSE;
        status := 0;

        // Transition back to IDLE state
        state := 0;

END_CASE;

END_FUNCTION_BLOCK

END_ST