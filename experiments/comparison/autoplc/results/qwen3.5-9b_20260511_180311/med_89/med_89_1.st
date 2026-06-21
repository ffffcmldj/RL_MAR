FUNCTION_BLOCK SoilTestingDeviceControl
VAR_INPUT
    StartButton : BOOL;
    SoilSampleDetected : BOOL;
END_VAR
VAR_OUTPUT
    NutrientPump : BOOL;
    pHAdjustmentPump : BOOL;
END_VAR
VAR
    pHSensorValue : REAL;
    NutrientSensorValue : REAL;
    TestingStatus : INT;
    NutrientThreshold : REAL := 0.7;
    pHThreshold : REAL := 6.5;
    i : INT;
END_VAR

TestingStatus := 0;
NutrientPump := FALSE;
pHAdjustmentPump := FALSE;

IF TestingStatus = 0 THEN
    pHSensorValue := 7.0;
    NutrientSensorValue := 0.5;
    
    IF StartButton = TRUE THEN
        TestingStatus := 1;
        NutrientPump := TRUE;
        pHAdjustmentPump := TRUE;
    END_IF;
ELSIF TestingStatus = 1 THEN
    NutrientPump := TRUE;
    pHAdjustmentPump := TRUE;
    
    IF NutrientSensorValue < 0.9 THEN
        NutrientSensorValue := NutrientSensorValue + 0.1;
    END_IF;
    
    IF pHSensorValue > 4.0 THEN
        pHSensorValue := pHSensorValue - 0.5;
    END_IF;
    
    IF SoilSampleDetected = TRUE THEN
        IF NutrientSensorValue >= NutrientThreshold AND pHSensorValue <= pHThreshold THEN
            TestingStatus := 2;
            NutrientPump := FALSE;
            pHAdjustmentPump := FALSE;
        END_IF;
    END_IF;
ELSIF TestingStatus = 2 THEN
    IF StartButton = TRUE THEN
        TestingStatus := 0;
        pHSensorValue := 7.0;
        NutrientSensorValue := 0.5;
        NutrientPump := FALSE;
        pHAdjustmentPump := FALSE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK