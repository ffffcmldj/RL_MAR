FUNCTION_BLOCK FB_Fibonacci_Calculator
    VAR_INPUT
        N : DINT := 5; // Input value for Fibonacci calculation
    END_VAR
    VAR_OUTPUT
        O : DINT := 1; // Output value for the N-th Fibonacci number
    END_VAR
    VAR
        F1 : DINT := 1; // First Fibonacci number
        F2 : DINT := 1; // Second Fibonacci number
        CNT : DINT := 2; // Counter for iterations
        Temp : DINT; // Temporary variable to hold the next Fibonacci number
    END_VAR

    // Input Validation
    IF N <= 2 THEN
        O := 1; // For N = 1 or N = 2, output is 1
    ELSE
        // Fibonacci Calculation
        WHILE CNT < N DO
            Temp := F1 + F2; // Calculate next Fibonacci number
            // Check for saturation
            IF Temp > 32767 THEN
                O := 32767; // Saturation arithmetic
                RETURN; // Exit the function block
            ELSE
                O := Temp; // Assign calculated Fibonacci number to output
            END_IF
            // Update Fibonacci numbers for next iteration
            F1 := F2; // Move F2 to F1
            F2 := O; // Move calculated value to F2
            CNT := CNT + 1; // Increment counter
        END_WHILE
    END_IF
END_FUNCTION_BLOCK