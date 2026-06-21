# No changes needed as the function block and function are correctly defined and utilized.

FUNCTION minimal(IN1: INT, IN2: INT) : INT
VAR
    result : INT; // Variable to hold the result
END_VAR

// Compare two integers and return the smaller one
IF IN1 < IN2 THEN
    result := IN1;
ELSE
    result := IN2;
END_IF;

RETURN result; // Return the result
END_FUNCTION