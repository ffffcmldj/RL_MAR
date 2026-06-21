FUNCTION_BLOCK SoilTestingDeviceControl
VAR_INPUT
    StartButton : BOOL; (* Input for starting the testing process *)
    SoilSampleDetected : BOOL; (* Input for detecting soil sample *)
END_VAR
VAR_OUTPUT
    NutrientPump : BOOL; (* Output to control nutrient pump *)
    pHAdjustmentPump : BOOL; (* Output to control pH adjustment pump *)
END_VAR
VAR
    pHSensorValue : REAL; (* Simulated pH sensor value *)
    NutrientSensorValue : REAL; (* Simulated nutrient sensor value *)
    TestingStatus : INT; (* Status: 0=Idle, 1=Testing, 2=Completed *)
    NutrientThreshold : REAL := 0.7; (* Nutrient level threshold for analysis *)
    pHThreshold : REAL := 6.5; (* pH level threshold for analysis *)
END_VAR

CASE TestingStatus OF
    0: (* Idle State *)
        (* Initialize sensor values *)
        pHSensorValue := 7.0;
        NutrientSensorValue := 0.5;
        
        (* Ensure pumps are deactivated *)
        NutrientPump := FALSE;
        pHAdjustmentPump := FALSE;
        
        (* Check for start condition *)
        IF StartButton THEN
            TestingStatus := 1;
            NutrientPump := TRUE;
            pHAdjustmentPump := TRUE;
        END_IF;
        
    1: (* Testing State *)
        (* Update sensor values during testing *)
        NutrientSensorValue := NutrientSensorValue + 0.1;
        pHSensorValue := pHSensorValue - 0.5;
        
        (* Enforce sensor value boundaries *)
        IF NutrientSensorValue > 0.9 THEN
            NutrientSensorValue := 0.9;
        END_IF;
        
        IF pHSensorValue < 4.0 THEN
            pHSensorValue := 4.0;
        END_IF;
        
        (* Check for completion condition *)
        IF SoilSampleDetected THEN
            IF (NutrientSensorValue >= NutrientThreshold) AND (pHSensorValue <= pHThreshold) THEN
                TestingStatus := 2;
                NutrientPump := FALSE;
                pHAdjustmentPump := FALSE;
            END_IF;
        END_IF;
        
    2: (* Completed State *)
        (* Ensure pumps are deactivated *)
        NutrientPump := FALSE;
        pHAdjustmentPump := FALSE;
        
        (* Reset to Idle when StartButton is released *)
        IF NOT StartButton THEN
            TestingStatus := 0;
        END_IF;
        
END_CASE;

END_FUNCTION_BLOCK