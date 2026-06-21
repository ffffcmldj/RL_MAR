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
END_VAR

// Reset has highest priority
IF reset THEN
    top := -1;
    error := FALSE;
    status := 16#0000;
    
// Push operation (prioritized over pop if both are active)
ELSIF push THEN
    IF top >= 3 THEN
        error := TRUE;
        status := 16#8A04;
    ELSE
        top := top + 1;
        stack[top] := item;
        error := FALSE;
        status := 16#0000;
    END_IF;
    
// Pop operation (only if push is not active)
ELSIF pop THEN
    IF top < 0 THEN
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
        
        // Return minimum value
        item := minValue;
        
        // Shift elements down to remove the minimum
        i := minIndex;
        WHILE i < top DO
            stack[i] := stack[i + 1];
            i := i + 1;
        END_WHILE;
        
        // Clear the vacated position (optional but clean)
        stack[top] := 0;
        
        // Update top index
        top := top - 1;
        
        error := FALSE;
        status := 16#0000;
    END_IF;
    
// No operation
ELSE
    error := FALSE;
    status := 16#0000;
END_IF;

END_FUNCTION_BLOCK