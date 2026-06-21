ructured-text
FUNCTION_BLOCK StackMin
VAR_INPUT
    push : BOOL;
    pop : BOOL;
    reset : BOOL;
END_VAR
VAR_OUTPUT
    error : BOOL;
    status : WORD;
END_VAR
VAR_IN_OUT
    item : INT;
    stack : ARRAY[0..3] OF INT;
END_VAR
VAR
    top : INT := -1; // Tracks the index of the top element; -1 means empty
    minIndex : INT; // Index of the minimum value found during pop operation
    minValue : INT; // Minimum value found during pop operation
    i : INT; // Loop variable for scanning the stack
END_VAR

// State Definitions
STATE: INT := 0; // 0: INITIALIZE, 1: PUSHING ITEM, 2: POPPING MINIMUM ITEM, 3: RESETTING STACK

// Main Logic
IF reset THEN
    top := -1; // Clear the stack
    error := FALSE;
    status := 16#0000;
    STATE := 0; // Transition to INITIALIZE
ELSE
    CASE STATE OF
        0: // INITIALIZE
            IF push AND top < 3 THEN
                STATE := 1; // Transition to PUSHING ITEM
            ELSIF pop AND top >= 0 THEN
                STATE := 2; // Transition to POPPING MINIMUM ITEM
            END_IF
            
        1: // PUSHING ITEM
            IF top < 3 THEN
                top := top + 1; // Increment top
                stack[top] := item; // Push item onto stack
                error := FALSE;
                status := 16#0000; // No error
            ELSE
                error := TRUE;
                status := 16#8A04; // Stack is full
            END_IF
            STATE := 0; // Transition back to INITIALIZE

        2: // POPPING MINIMUM ITEM
            IF top >= 0 THEN
                minValue := stack[0];
                minIndex := 0;
                // Find minimum value and its index
                FOR i := 1 TO top DO
                    IF stack[i] < minValue THEN
                        minValue := stack[i];
                        minIndex := i;
                    END_IF
                END_FOR
                item := minValue; // Store minimum value in item
                // Remove the minimum value by shifting elements
                FOR i := minIndex TO top - 1 DO
                    stack[i] := stack[i + 1];
                END_FOR
                top := top - 1; // Decrement top
                error := FALSE;
                status := 16#0000; // No error
            ELSE
                error := TRUE;
                status := 16#8A05; // Stack is empty
            END_IF
            STATE := 0; // Transition back to INITIALIZE
    END_CASE
END_IF

END_FUNCTION_BLOCK