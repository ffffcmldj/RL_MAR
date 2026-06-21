FUNCTION_BLOCK FB_LinearizeValue
VAR_INPUT 
InputValue : REAL; 
END_VAR

VAR_OUTPUT 
LinearizedValue : REAL; 
Error : BOOL; 
Status : WORD; 
END_VAR

VAR 
TempValue : REAL; 
END_VAR

IF InputValue < 1200.0 THEN
    LinearizedValue := 150.0;
    Error := TRUE;
    Status := 16#8001;
ELSIF InputValue > 7000.0 THEN
    LinearizedValue := 720.0;
    Error := TRUE;
    Status := 16#8001;
ELSE
    Error := FALSE;
    Status := 16#0000;
    
    IF InputValue <= 3600.0 THEN
        TempValue := 150.0 + (InputValue - 1200.0) * (240.0 - 150.0) / (3600.0 - 1200.0);
        LinearizedValue := TempValue;
    ELSIF InputValue <= 4800.0 THEN
        TempValue := 240.0 + (InputValue - 3600.0) * (560.0 - 240.0) / (4800.0 - 3600.0);
        LinearizedValue := TempValue;
    ELSE
        TempValue := 560.0 + (InputValue - 4800.0) * (720.0 - 560.0) / (7000.0 - 4800.0);
        LinearizedValue := TempValue;
    END_IF;
END_IF;

END_FUNCTION_BLOCK