FUNCTION_BLOCK PrecisionEngravingMachine
VAR_INPUT
    DesignSelection : INT;
END_VAR

VAR_OUTPUT
    ZAxisMotor : BOOL := FALSE;
    EngravingMotor : BOOL := FALSE;
END_VAR

VAR
    CalculatedDepth : REAL := 0.0;
    CalculatedSpeed : REAL := 0.0;
END_VAR

VAR
    PreviousDesignSelection : INT := 0;
END_VAR

// Main logic to control engraving machine based on design selection
IF DesignSelection <> PreviousDesignSelection THEN
    CASE DesignSelection OF
        1:
            CalculatedSpeed := 10.0;
            CalculatedDepth := 0.1;
            ZAxisMotor := TRUE;
            EngravingMotor := TRUE;
        2:
            CalculatedSpeed := 8.0;
            CalculatedDepth := 0.2;
            ZAxisMotor := TRUE;
            EngravingMotor := TRUE;
        3:
            CalculatedSpeed := 12.0;
            CalculatedDepth := 0.15;
            ZAxisMotor := TRUE;
            EngravingMotor := TRUE;
        ELSE
            CalculatedSpeed := 0.0;
            CalculatedDepth := 0.0;
            ZAxisMotor := FALSE;
            EngravingMotor := FALSE;
    END_CASE;
    // Update the previous design selection to the current one
    PreviousDesignSelection := DesignSelection;
END_IF

END_FUNCTION_BLOCK