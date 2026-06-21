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
        pHSensorValue := 7.0;
        NutrientSensorValue := 0.5;
        NutrientPump := FALSE;
        pHAdjustmentPump := FALSE;
        
        IF StartButton THEN
            TestingStatus := 1;
            NutrientPump := TRUE;
            pHAdjustmentPump := TRUE;
        END_IF;
        
    1: (* Testing State *)
        (* First check for completion conditions *)
        IF SoilSampleDetected THEN
            IF (NutrientSensorValue >= NutrientThreshold) AND (pHSensorValue <= pHThreshold) THEN
                TestingStatus := 2;
                NutrientPump := FALSE;
                pHAdjustmentPump := FALSE;
            END_IF;
        END_IF;
        
        (* Only update sensor values if still in Testing state *)
        IF TestingStatus = 1 THEN
            (* Update NutrientSensorValue with upper limit *)
            NutrientSensorValue := NutrientSensorValue + 0.1;
            IF NutrientSensorValue > 0.9 THEN
                NutrientSensorValue := 0.9;
            END_IF;
            
            (* Update pHSensorValue with lower limit *)
            pHSensorValue := pHSensorValue - 0.5;
            IF pHSensorValue < 4.0 THEN
                pHSensorValue := 4.0;
            END_IF;
        END_IF;
        
    2: (* Completed State *)
        NutrientPump := FALSE;
        pHAdjustmentPump := FALSE;
        
        (* Stay in Completed state - requires external reset *)
        (* To reset, set TestingStatus := 0 from outside *)
        
    ELSE
        (* Default case - reset to Idle state *)
        TestingStatus := 0;
END_CASE;

END_FUNCTION_BLOCK;