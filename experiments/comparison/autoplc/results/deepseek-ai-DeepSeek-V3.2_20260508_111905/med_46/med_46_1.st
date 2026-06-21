FUNCTION_BLOCK PrecisionEngravingMachine
VAR_INPUT
    DesignSelection : INT;
    EngravingDepth : REAL;
    EngravingSpeed : REAL;
END_VAR

VAR_OUTPUT
    ZAxisMotor : BOOL;
    EngravingMotor : BOOL;
END_VAR

VAR
    CalculatedDepth : REAL;
    CalculatedSpeed : REAL;
END_VAR

    // Main execution logic
    CASE DesignSelection OF
        1: 
            CalculatedDepth := 0.1;
            CalculatedSpeed := 10.0;
            ZAxisMotor := TRUE;
            EngravingMotor := TRUE;
            
        2: 
            CalculatedDepth := 0.2;
            CalculatedSpeed := 8.0;
            ZAxisMotor := TRUE;
            EngravingMotor := TRUE;
            
        3: 
            CalculatedDepth := 0.15;
            CalculatedSpeed := 12.0;
            ZAxisMotor := TRUE;
            EngravingMotor := TRUE;
            
        ELSE
            // Invalid design selection
            CalculatedDepth := 0.0;
            CalculatedSpeed := 0.0;
            ZAxisMotor := FALSE;
            EngravingMotor := FALSE;
    END_CASE;
    
    // Assign calculated values to output parameters
    EngravingDepth := CalculatedDepth;
    EngravingSpeed := CalculatedSpeed;
    
END_FUNCTION_BLOCK