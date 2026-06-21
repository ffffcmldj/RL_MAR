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
    i : INT; // Loop variable
    minIndex : INT; // Index of minimum value
    minValue : INT; // Minimum value
END_VAR

// Reset handling - highest priority
IF reset THEN
    top := -1;
    error := FALSE;
    status := 16#0000;
    
// Push operation - next priority
ELSIF push THEN
    IF top >= 3 THEN
        // Stack is full
        error := TRUE;
        status := 16#8A04;
    ELSE
        // Perform push
        top := top + 1;
        stack[top] := item;
        error := FALSE;
        status := 16#0000;
    END_IF;
    
// Pop operation - lowest priority
ELSIF pop THEN
    IF top < 0 THEN
        // Stack is empty
        error := TRUE;
        status := 16#8A05;
    ELSE
        // Find minimum value and its index
        minIndex := 0;
        minValue := stack[0];
        
        i := 1;
        WHILE i <= top DO
            IF stack[i] < minValue THEN
                minValue := stack[i];
                minIndex := i;
            END_IF;
            i := i + 1;
        END_WHILE;
        
        // Store minimum value in output
        item := minValue;
        
        // Shift elements down to remove the minimum element
        i := minIndex;
        WHILE i < top DO
            stack[i] := stack[i + 1];
            i := i + 1;
        END_WHILE;
        
        // Decrement top
        top := top - 1;
        
        error := FALSE;
        status := 16#0000;
    END_IF;
    
// No operation
ELSE
    // Keep current state
END_IF;

END_FUNCTION_BLOCK