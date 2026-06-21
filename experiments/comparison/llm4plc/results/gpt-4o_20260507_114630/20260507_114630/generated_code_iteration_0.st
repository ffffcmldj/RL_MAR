plaintext
START_ST
FUNCTION_BLOCK StackMin
VAR_INPUT
    push : BOOL; // Trigger to push an item onto the stack
    pop : BOOL;  // Trigger to pop the minimum item from the stack
    reset : BOOL; // Trigger to reset the stack
END_VAR
VAR_OUTPUT
    error : BOOL; // TRUE if an error occurred
    status : WORD; // Status code indicating success or specific error
END_VAR
VAR_IN_OUT
    item : INT; // Value to push or the value popped
    stack : ARRAY[0..3] OF INT; // Stack storage
END_VAR
VAR
    top : INT := -1; // Tracks the index of the top element (-1 means empty)
    minIndex : INT; // Index of the minimum value in the stack
    i : INT; // Loop variable for iterations
    currentState : INT := 0; // State variable for FSM
END_VAR

// State Definitions
// 0: IDLE
// 1: RESET STACK
// 2: PUSH ITEM
// 3: POP MINIMUM ITEM

CASE currentState OF
    // STATE 0: IDLE
    0:
        IF reset THEN
            currentState := 1; // Transition to RESET STACK
        ELSIF push THEN
            currentState := 2; // Transition to PUSH ITEM
        ELSIF pop THEN
            currentState := 3; // Transition to POP MINIMUM ITEM
        ELSE
            error := FALSE;
            status := 16#0000; // No error
        END_IF;

    // STATE 1: RESET STACK
    1:
        top := -1; // Clear the stack
        error := FALSE;
        status := 16#0000; // No error
        currentState := 0; // Return to IDLE

    // STATE 2: PUSH ITEM
    2:
        IF top = 3 THEN // Check if stack is full
            error := TRUE;
            status := 16#8A04; // Stack is full
        ELSE
            top := top + 1; // Increment top index
            stack[top] := item; // Add item to stack
            error := FALSE;
            status := 16#0000; // No error
        END_IF;
        currentState := 0; // Return to IDLE

    // STATE 3: POP MINIMUM ITEM
    3:
        IF top = -1 THEN // Check if stack is empty
            error := TRUE;
            status := 16#8A05; // Stack is empty
        ELSE
            // Find the minimum value and its index
            minIndex := 0; // Initialize minIndex
            FOR i := 1 TO top DO
                IF stack[i] < stack[minIndex] THEN
                    minIndex := i; // Update minIndex if a smaller value is found
                END_IF;
            END_FOR;

            // Return the minimum value
            item := stack[minIndex];

            // Shift elements above minIndex down by one
            FOR i := minIndex TO top - 1 DO
                stack[i] := stack[i + 1];
            END_FOR;

            top := top - 1; // Decrement top index
            error := FALSE;
            status := 16#0000; // No error
        END_IF;
        currentState := 0; // Return to IDLE
END_CASE;
END_FUNCTION_BLOCK
END_ST