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
    top : INT := -1;
    i : INT;
    minIndex : INT;
    minValue : INT;
    j : INT;
END_VAR

// Reset operation takes highest priority
IF reset THEN
    top := -1;
    error := FALSE;
    status := 16#0000;
ELSIF push THEN
    // Push operation
    IF top >= 3 THEN
        // Stack is full
        error := TRUE;
        status := 16#8A04;
    ELSE
        // Add item to stack
        top := top + 1;
        stack[top] := item;
        error := FALSE;
        status := 16#0000;
    END_IF;
ELSIF pop THEN
    // Pop minimum operation
    IF top < 0 THEN
        // Stack is empty
        error := TRUE;
        status := 16#8A05;
    ELSE
        // Find minimum value and its index
        minIndex := 0;
        minValue := stack[0];
        
        FOR i := 1 TO top DO
            IF stack[i] < minValue THEN
                minValue := stack[i];
                minIndex := i;
            END_IF;
        END_FOR;
        
        // Return minimum value via item
        item := minValue;
        
        // Shift elements down to remove the minimum
        FOR j := minIndex TO top - 1 DO
            stack[j] := stack[j + 1];
        END_FOR;
        
        // Clear the last position (optional but clean)
        stack[top] := 0;
        
        // Update top index
        top := top - 1;
        
        error := FALSE;
        status := 16#0000;
    END_IF;
ELSE
    // No operation requested
    error := FALSE;
    status := 16#0000;
END_IF;
END_FUNCTION_BLOCK