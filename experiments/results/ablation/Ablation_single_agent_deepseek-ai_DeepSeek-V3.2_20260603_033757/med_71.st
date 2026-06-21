FUNCTION_BLOCK FB_Fibonacci_Calculator
VAR_INPUT
    N : DINT := 5;
END_VAR
VAR_OUTPUT
    O : DINT := 1;
END_VAR
VAR
    F1 : DINT := 1;
    F2 : DINT := 1;
    CNT : DINT := 2;
    Temp : DINT;
END_VAR

// Handle edge cases and calculate Fibonacci with saturation
IF N <= 0 THEN
    O := 0;
ELSIF N <= 2 THEN
    O := 1;
ELSE
    // Initialize Fibonacci sequence
    F1 := 1;
    F2 := 1;
    CNT := 2;
    
    // Calculate Fibonacci numbers up to N-th term
    WHILE CNT < N DO
        // Calculate next Fibonacci number with saturation check
        Temp := F1 + F2;
        
        // Apply saturation arithmetic - limit to INT maximum (32767)
        IF Temp > 32767 THEN
            Temp := 32767;
        END_IF;
        
        // Shift values for next iteration
        F1 := F2;
        F2 := Temp;
        
        // Increment counter
        CNT := CNT + 1;
    END_WHILE;
    
    // Output the N-th Fibonacci number
    O := F2;
END_IF;
END_FUNCTION_BLOCK