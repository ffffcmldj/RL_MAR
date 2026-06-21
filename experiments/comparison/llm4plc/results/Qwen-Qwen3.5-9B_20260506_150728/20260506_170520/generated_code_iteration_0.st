START_ST
FUNCTION_BLOCK FB_ConditionalSelectAndAggregate
VAR_INPUT
Z : INT;
END_VAR
VAR_OUTPUT
NEW_Z : INT;
END_VAR
VAR
state : INT;
A_X : INT := 42;
A_Y : INT := 333;
temp_selection : INT;
END_VAR

state := 0;

CASE state OF
    0:
        NEW_Z := 0;
        state := 1;
    1:
        IF A_X > Z THEN
            temp_selection := A_Y;
        ELSE
            temp_selection := Z;
        END_IF;
        NEW_Z := temp_selection;
        state := 2;
    2:
        NEW_Z := NEW_Z + A_X + A_Y;
        state := 0;
END_CASE;

END_FUNCTION_BLOCK
END_ST