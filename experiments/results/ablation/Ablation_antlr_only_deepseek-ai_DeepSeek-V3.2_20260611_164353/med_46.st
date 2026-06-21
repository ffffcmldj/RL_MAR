FUNCTION_BLOCK PrecisionEngravingMachine
VAR_INPUT
    DesignSelection : INT;
END_VAR

VAR_OUTPUT
    EngravingDepth : REAL;
    EngravingSpeed : REAL;
    ZAxisMotor : BOOL;
    EngravingMotor : BOOL;
END_VAR

VAR
    CalculatedDepth : REAL;
    CalculatedSpeed : REAL;
END_VAR

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

EngravingSpeed := CalculatedSpeed;
EngravingDepth := CalculatedDepth;

END_FUNCTION_BLOCK