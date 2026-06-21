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
    minIndex : INT;
    i : INT;
END_VAR

// Main logic
IF reset THEN
    // Reset operation
    top := -1;
    error := FALSE;
    status := 16#0000;
ELSIF push THEN
    // Push operation
    IF top < 3 THEN
        top := top + 1;
        stack[top] := item;
        error := FALSE;
        status := 16#0000;
    ELSE
        error := TRUE;
        status := 16#8A04; // Stack is full
    END_IF;
ELSIF pop THEN
    // Pop operation
    IF top > -1 THEN
        // Find the minimum value and its index
        minIndex := 0;
        FOR i := 1 TO top DO
            IF stack[i] < stack[minIndex] THEN
                minIndex := i;
            END_IF;
        END_FOR;
        
        // Store the minimum value in 'item'
        item := stack[minIndex];
        
        // Shift elements down to remove the minimum value
        FOR i := minIndex TO top - 1 DO
            stack[i] := stack[i + 1];
        END_FOR;
        
        // Decrement the top index
        top := top - 1;
        
        error := FALSE;
        status := 16#0000;
    ELSE
        error := TRUE;
        status := 16#8A05; // Stack is empty
    END_IF;
END_IF;

END_FUNCTION_BLOCK