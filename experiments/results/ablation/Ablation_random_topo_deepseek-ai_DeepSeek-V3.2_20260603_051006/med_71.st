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
    MaxValue : DINT := 32767;
    Temp : DINT;
END_VAR

// Handle edge cases for N <= 2
IF N <= 2 THEN
    O := 1;
    RETURN;
END_IF

// Initialize for N > 2
F1 := 1;
F2 := 1;
CNT := 2;

// Calculate Fibonacci sequence with saturation
WHILE CNT < N DO
    // Check for overflow before calculation
    IF (F1 > (MaxValue - F2)) THEN
        O := MaxValue;
        RETURN;
    END_IF
    
    Temp := F1 + F2;
    F1 := F2;
    F2 := Temp;
    CNT := CNT + 1;
END_WHILE

O := F2;
END_FUNCTION_BLOCK

PROGRAM Main
VAR
    FibonacciCalc : FB_Fibonacci_Calculator;
    InputValue : DINT := 5;
    Result : DINT;
END_VAR

FibonacciCalc(N := InputValue);
Result := FibonacciCalc.O;
END_PROGRAM