FUNCTION_BLOCK HomeBrewingSystem
VAR_INPUT
    TemperatureSensor : REAL;
    WaterFlowSensor : REAL;
    BrewingStartTime : TIME;
    BrewingDuration : TIME;
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL;
    AgitationMotor : BOOL;
    HopsDispenser : BOOL;
    FermentationTank : BOOL;
END_VAR
VAR
    CurrentTime : TIME;
    ElapsedTime : TIME;
    HopsThreshold : TIME;
    FermentationThreshold : TIME;
END_VAR

CurrentTime := IEC_TIME.TOD();
ElapsedTime := CurrentTime - BrewingStartTime;

HopsThreshold := T#5H;
FermentationThreshold := T#48H;

IF TemperatureSensor < 65.0 THEN
    HeatingElement := TRUE;
ELSE
    HeatingElement := FALSE;
END_IF;

IF WaterFlowSensor > 0.5 THEN
    AgitationMotor := TRUE;
ELSE
    AgitationMotor := FALSE;
END_IF;

IF ElapsedTime >= HopsThreshold THEN
    HopsDispenser := TRUE;
ELSE
    HopsDispenser := FALSE;
END_IF;

IF ElapsedTime >= FermentationThreshold THEN
    FermentationTank := TRUE;
ELSE
    FermentationTank := FALSE;
END_IF;

END_FUNCTION_BLOCK