pascal
START_ST
FUNCTION_BLOCK MultiPumpCtrl
VAR_INPUT
    mode : BOOL; // FALSE = Manual mode, TRUE = Automatic mode
    start : BOOL; // Start button
    stop : BOOL; // Stop button
    priorities : ARRAY[1..5] OF INT; // Priority levels of pumps
    selections : ARRAY[1..5] OF BOOL; // Manual mode selections
END_VAR
VAR_OUTPUT
    RunComds : ARRAY[1..5] OF BOOL; // Pump run commands
END_VAR
VAR
    state : INT; // Current state of the FSM
    i : INT; // Loop index
    j : INT; // Secondary loop index
    maxPriority : INT; // Maximum priority found
    maxIndex : INT; // Index of the pump with the maximum priority
    runCount : INT; // Counter for pumps selected in automatic mode
    usedInAuto : ARRAY[1..5] OF BOOL; // Tracks pumps already selected in automatic mode
END_VAR

// Initialization of the FSM
IF NOT start AND NOT stop THEN
    state := 0; // Default to IDLE state
END_IF

// FSM Logic
CASE state OF
    // STATE 0: IDLE
    0:
        // Default outputs: all pumps stopped
        FOR i := 1 TO 5 DO
            RunComds[i] := FALSE;
        END_FOR

        // Transitions
        IF stop THEN
            state := 1; // Transition to STOP_ALL_PUMPS
        ELSIF NOT mode AND start AND NOT stop THEN
            state := 2; // Transition to MANUAL_MODE_OPERATION
        ELSIF mode AND start AND NOT stop THEN
            state := 3; // Transition to AUTOMATIC_MODE_OPERATION
        END_IF

    // STATE 1: STOP_ALL_PUMPS
    1:
        // Stop all pumps
        FOR i := 1 TO 5 DO
            RunComds[i] := FALSE;
        END_FOR

        // Transition
        IF NOT stop THEN
            state := 0; // Transition back to IDLE
        END_IF

    // STATE 2: MANUAL_MODE_OPERATION
    2:
        // Set RunComds based on selections array
        FOR i := 1 TO 5 DO
            RunComds[i] := selections[i];
        END_FOR

        // Transitions
        IF NOT start OR stop THEN
            state := 0; // Transition back to IDLE
        END_IF

    // STATE 3: AUTOMATIC_MODE_OPERATION
    3:
        // Initialize variables
        FOR i := 1 TO 5 DO
            usedInAuto[i] := FALSE;
        END_FOR
        runCount := 0;

        // Select 3 pumps with the highest priorities
        WHILE runCount < 3 DO
            maxPriority := -1; // Reset maxPriority for each iteration
            maxIndex := -1; // Reset maxIndex for each iteration

            // Find the pump with the highest priority not already used
            FOR i := 1 TO 5 DO
                IF (NOT usedInAuto[i]) AND (priorities[i] > maxPriority) THEN
                    maxPriority := priorities[i];
                    maxIndex := i;
                END_IF
            END_FOR

            // If a valid pump is found, mark it as used and set its RunComd
            IF maxIndex <> -1 THEN
                RunComds[maxIndex] := TRUE;
                usedInAuto[maxIndex] := TRUE;
                runCount := runCount + 1;
            END_IF
        END_WHILE

        // Ensure remaining pumps are off
        FOR i := 1 TO 5 DO
            IF NOT usedInAuto[i] THEN
                RunComds[i] := FALSE;
            END_IF
        END_FOR

        // Transitions
        IF NOT start OR stop THEN
            state := 0; // Transition back to IDLE
        END_IF

END_CASE
END_FUNCTION_BLOCK
END_ST