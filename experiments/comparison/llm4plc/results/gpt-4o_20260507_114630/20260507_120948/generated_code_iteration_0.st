plaintext
START_ST
FUNCTION_BLOCK FB_ConditionalSelectAndAggregate
VAR_INPUT
    Z : INT; // External input value for comparison and potential selection
END_VAR
VAR
    A_X : INT := 42; // Threshold for comparison
    A_Y : INT := 333; // Alternative value for selection
END_VAR
VAR_OUTPUT
    NEW_Z : INT; // Result of the selection and aggregation
END_VAR

// Conditional Selection
IF A_X > Z THEN
    NEW_Z := A_Y; // Select A_Y if A_X > Z
ELSE
    NEW_Z := Z; // Otherwise, select Z
END_IF;

// Aggregation
NEW_Z := NEW_Z + A_X + A_Y;

END_FUNCTION_BLOCK
END_ST