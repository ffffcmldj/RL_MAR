FUNCTION_BLOCK StackMin
    VAR_INPUT
        push : BOOL;
        pop : BOOL;
        reset : BOOL;
    END_VAR

    VAR_OUTPUT
        error : BOOL := FALSE;
        status : WORD := 16#0000;
    END_VAR

    VAR_IN_OUT
        item : INT;
        stack : ARRAY[0..3] OF INT;
    END_VAR

    VAR
        top : INT := -1; // Tracks the index of the top element; -1 means empty
        minValue : INT;
        minIndex : INT;
        i : INT; // Loop variable
    END_VAR

    // Reset operation
    IF reset THEN
        top := -1; // Clear the stack
        error := FALSE;
        status := 16#0000;
    ELSE
        // Push operation
        IF push AND (top < 3) THEN
            top := top + 1; // Increment top index
            stack[top] := item; // Push item onto stack
            error := FALSE;
            status := 16#0000; // No error
        ELSIF push AND (top = 3) THEN
            error := TRUE; // Stack is full
            status := 16#8A04; // Error code for full stack
        END_IF;

        // Pop operation
        IF pop AND (top >= 0) THEN
            // Initialize minValue and minIndex
            minValue := stack[0];
            minIndex := 0;

            // Find the minimum value and its index
            FOR i := 1 TO top DO
                IF stack[i] < minValue THEN
                    minValue := stack[i];
                    minIndex := i;
                END_IF;
            END_FOR;

            // Store the minimum value in item
            item := minValue;

            // Shift elements down to remove the minimum value
            FOR i := minIndex TO top - 1 DO
                stack[i] := stack[i + 1];
            END_FOR;

            // Decrement top index
            top := top - 1;

            error := FALSE;
            status := 16#0000; // No error
        ELSIF pop AND (top = -1) THEN
            error := TRUE; // Stack is empty
            status := 16#8A05; // Error code for empty stack
        END_IF;
    END_IF;
END_FUNCTION_BLOCK