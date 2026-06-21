FUNCTION_BLOCK FB_ConditionalSelectAndAggregate
VAR_INPUT
    Z : INT;
END_VAR
VAR
    A_X : INT := 42;
    A_Y : INT := 333;
END_VAR
VAR_OUTPUT
    NEW_Z : INT;
END_VAR

IF A_X > Z THEN
    NEW_Z := A_Y;
ELSE
    NEW_Z := Z;
END_IF;
NEW_Z := NEW_Z + A_X + A_Y;
END_FUNCTION_BLOCK