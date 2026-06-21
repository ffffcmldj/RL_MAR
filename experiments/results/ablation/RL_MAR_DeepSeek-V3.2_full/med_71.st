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

// Handle edge cases: N <= 2 returns 1
IF N <= 2 THEN
    O := 1;
    RETURN;
END_IF;

// Initialize for calculation
F1 := 1;
F2 := 1;
CNT := 2;

// Calculate Fibonacci sequence up to N-th term
WHILE CNT < N DO
    // Check for potential overflow before calculation
    IF (F1 > 32767 - F2) THEN
        // Saturation: if sum would exceed 32767, saturate to 32767
        O := 32767;
        RETURN;
    END_IF;
    
    // Calculate next Fibonacci number
    Temp := F1 + F2;
    F1 := F2;
    F2 := Temp;
    CNT := CNT + 1;
END_WHILE;

// Set output to the N-th Fibonacci number
O := F2;

// Final saturation check (in case F2 already exceeded 32767)
IF O > 32767 THEN
    O := 32767;
END_IF;

END_FUNCTION_BLOCK