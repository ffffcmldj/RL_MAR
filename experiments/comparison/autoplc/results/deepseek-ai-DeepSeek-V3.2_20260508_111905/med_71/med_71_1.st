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
    i : DINT;
    tempSum : DINT;
END_VAR

// Reset internal state if N is less than or equal to current CNT
IF N <= CNT THEN
    F1 := 1;
    F2 := 1;
    CNT := 2;
END_IF

// Handle edge cases for N <= 2
IF N <= 2 THEN
    O := 1;
    RETURN;
END_IF

// Compute Fibonacci numbers from current CNT up to N
FOR i := CNT TO N-1 BY 1 DO
    // Calculate next Fibonacci number with saturation
    tempSum := F1 + F2;
    
    // Apply saturation arithmetic - limit to 32767
    IF tempSum > 32767 THEN
        tempSum := 32767;
    END_IF
    
    // Update Fibonacci sequence
    F1 := F2;
    F2 := tempSum;
    
    // Update counter
    CNT := i + 1;
END_FOR

// Set output to the N-th Fibonacci number
O := F2;

END_FUNCTION_BLOCK