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
        CalculatedDepth : REAL := 0.0;
        CalculatedSpeed : REAL := 0.0;
    END_VAR

    // Initialization
    ZAxisMotor := FALSE;
    EngravingMotor := FALSE;

    // Input Handling
    IF DesignSelection = 1 THEN
        CalculatedDepth := 0.1;
        CalculatedSpeed := 10.0;
        ZAxisMotor := TRUE;
        EngravingMotor := TRUE;
    ELSIF DesignSelection = 2 THEN
        CalculatedDepth := 0.2;
        CalculatedSpeed := 8.0;
        ZAxisMotor := TRUE;
        EngravingMotor := TRUE;
    ELSIF DesignSelection = 3 THEN
        CalculatedDepth := 0.15;
        CalculatedSpeed := 12.0;
        ZAxisMotor := TRUE;
        EngravingMotor := TRUE;
    ELSE
        CalculatedDepth := 0.0;
        CalculatedSpeed := 0.0;
        ZAxisMotor := FALSE;
        EngravingMotor := FALSE;
    END_IF;

    // Output Assignment
    EngravingDepth := CalculatedDepth;
    EngravingSpeed := CalculatedSpeed;

END_FUNCTION_BLOCK