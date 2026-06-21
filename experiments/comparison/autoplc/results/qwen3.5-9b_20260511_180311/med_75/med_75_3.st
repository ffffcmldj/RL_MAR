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
    TargetTemp : REAL;
    FlowThreshold : REAL;
    HopsTime : TIME;
    FermentTime : TIME;
END_VAR

CurrentTime := T#0s;
TargetTemp := 65.0;
FlowThreshold := 0.5;
HopsTime := T#5h;
FermentTime := T#48h;

IF CurrentTime = T#0s THEN
    CurrentTime := BrewingStartTime;
END_IF;

ElapsedTime := CurrentTime - BrewingStartTime;

IF ElapsedTime < T#0s THEN
    ElapsedTime := T#0s;
END_IF;

IF TemperatureSensor < TargetTemp THEN
    HeatingElement := TRUE;
ELSE
    HeatingElement := FALSE;
END_IF;

IF WaterFlowSensor > FlowThreshold THEN
    AgitationMotor := TRUE;
ELSE
    AgitationMotor := FALSE;
END_IF;

IF ElapsedTime >= HopsTime THEN
    HopsDispenser := TRUE;
ELSE
    HopsDispenser := FALSE;
END_IF;

IF ElapsedTime >= FermentTime THEN
    FermentationTank := TRUE;
ELSE
    FermentationTank := FALSE;
END_IF;

END_FUNCTION_BLOCK