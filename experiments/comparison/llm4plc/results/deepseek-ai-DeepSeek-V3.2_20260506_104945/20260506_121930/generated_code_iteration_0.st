START_ST
FUNCTION_BLOCK FB_ConditionalSelectAndAggregate
VAR_INPUT
Z : INT;
END_VAR
VAR
A_X : INT := 42;
A_Y : INT := 333;
tempSelected : INT;
END_VAR
VAR_OUTPUT
NEW_Z : INT;
END_VAR

IF A_X > Z THEN
    tempSelected := A_Y;
ELSE
    tempSelected := Z;
END_IF;
NEW_Z := tempSelected + A_X + A_Y;

END_FUNCTION_BLOCK
END_ST