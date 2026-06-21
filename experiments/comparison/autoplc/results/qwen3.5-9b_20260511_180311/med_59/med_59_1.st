FUNCTION_BLOCK FB_ConditionalSelectAndAggregate
VAR_INPUT
Z : INT;
END_VAR
VAR
A_X : INT := 42;
A_Y : INT := 333;
Selected_Value : INT;
END_VAR
VAR_OUTPUT
NEW_Z : INT;
END_VAR

IF A_X > Z THEN
    Selected_Value := A_Y;
ELSE
    Selected_Value := Z;
END_IF;

NEW_Z := Selected_Value + A_X + A_Y;

END_FUNCTION_BLOCK