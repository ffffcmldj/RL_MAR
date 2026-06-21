FUNCTION_BLOCK FB_Sum
VAR_INPUT
    maxValue : INT;
END_VAR
VAR_OUTPUT
    wData : WORD;
END_VAR
VAR
    II : INT;
    tempSum : DINT; // Temporary variable for summation
END_VAR

// Initialize
tempSum := 0;
wData := 0;

// Summation loop
FOR II := 0 TO maxValue DO
    tempSum := tempSum + II;
END_FOR

// Assign result with range checking
IF tempSum >= 0 AND tempSum <= 65535 THEN
    wData := WORD(tempSum);
ELSE
    wData := 0; // Handle overflow by resetting to 0
END_IF
END_FUNCTION_BLOCK