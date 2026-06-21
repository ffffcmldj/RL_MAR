FUNCTION_BLOCK FB_ConditionalSelectAndAggregate
    VAR_INPUT
        Z : INT;  
    END_VAR
    
    VAR
        A_X : INT := 42;  
        A_Y : INT := 333; 
        SelectedValue : INT; 
    END_VAR
    
    VAR_OUTPUT
        NEW_Z : INT;  
    END_VAR
    
    IF A_X > Z THEN
        SelectedValue := A_Y; 
    ELSE
        SelectedValue := Z; 
    END_IF;
    
    NEW_Z := SelectedValue; 
    NEW_Z := NEW_Z + A_X + A_Y; 
END_FUNCTION_BLOCK