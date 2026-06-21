FUNCTION_BLOCK FB_Fibonacci_Calculator
    VAR_INPUT
        N : DINT := 5; // Position in the Fibonacci sequence
    END_VAR
    VAR_OUTPUT
        O : DINT := 1; // Result of the Fibonacci calculation
    END_VAR
    VAR
        F1 : DINT := 1; // First Fibonacci number
        F2 : DINT := 1; // Second Fibonacci number
        CNT : DINT := 2; // Counter for the sequence position
        Temp : DINT; // Temporary variable for calculation
    END_VAR

    // Edge case handling for N <= 2
    IF N <= 2 THEN
        O := 1;
    ELSE
        // Fibonacci calculation for N > 2
        FOR CNT := 3 TO N DO
            Temp := F1 + F2; // Calculate next Fibonacci number
            F1 := F2; // Update F1 to the previous F2
            F2 := Temp; // Update F2 to the new Fibonacci number

            // Check for overflow condition
            IF Temp > 32767 THEN
                O := 32767; // Saturation arithmetic
                RETURN; // Exit the loop early
            END_IF
        END_FOR
        O := F2; // Assign the result to output
    END_IF
END_FUNCTION_BLOCK