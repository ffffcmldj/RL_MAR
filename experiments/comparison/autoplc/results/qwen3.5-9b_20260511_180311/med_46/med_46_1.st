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
    IsDesignValid : BOOL;
END_VAR

IsDesignValid := (DesignSelection = 1) OR (DesignSelection = 2) OR (DesignSelection = 3);

IF IsDesignValid THEN
    CASE DesignSelection OF
        1:
            CalculatedSpeed := 10.0;
            CalculatedDepth := 0.1;
        2:
            CalculatedSpeed := 8.0;
            CalculatedDepth := 0.2;
        3:
            CalculatedSpeed := 12.0;
            CalculatedDepth := 0.15;
    END_CASE
    ZAxisMotor := TRUE;
    EngravingMotor := TRUE;
ELSE
    CalculatedSpeed := 0.0;
    CalculatedDepth := 0.0;
    ZAxisMotor := FALSE;
    EngravingMotor := FALSE;
END_IF

END_FUNCTION_BLOCK