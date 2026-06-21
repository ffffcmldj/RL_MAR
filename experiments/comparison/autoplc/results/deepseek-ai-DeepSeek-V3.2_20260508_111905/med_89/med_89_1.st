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

(* Main execution logic *)
CASE TestingStatus OF
    0: (* Idle state *)
        (* Initialize sensor values *)
        pHSensorValue := 7.0;
        NutrientSensorValue := 0.5;
        
        (* Ensure pumps are off *)
        NutrientPump := FALSE;
        pHAdjustmentPump := FALSE;
        
        (* Check for transition to Testing state *)
        IF StartButton THEN
            TestingStatus := 1;
        END_IF;
        
    1: (* Testing state *)
        (* Activate both pumps *)
        NutrientPump := TRUE;
        pHAdjustmentPump := TRUE;
        
        (* Update simulated sensor values with clamping *)
        (* Increment NutrientSensorValue by 0.1, max 0.9 *)
        NutrientSensorValue := NutrientSensorValue + 0.1;
        IF NutrientSensorValue > 0.9 THEN
            NutrientSensorValue := 0.9;
        END_IF;
        
        (* Decrement pHSensorValue by 0.5, min 4.0 *)
        pHSensorValue := pHSensorValue - 0.5;
        IF pHSensorValue < 4.0 THEN
            pHSensorValue := 4.0;
        END_IF;
        
        (* Check for completion criteria *)
        IF SoilSampleDetected THEN
            IF (NutrientSensorValue >= NutrientThreshold) AND (pHSensorValue <= pHThreshold) THEN
                TestingStatus := 2;
            END_IF;
        END_IF;
        
    2: (* Completed state *)
        (* Deactivate both pumps *)
        NutrientPump := FALSE;
        pHAdjustmentPump := FALSE;
        
        (* Remain in Completed state - no further action *)
        
    ELSE
        (* Handle unexpected state by resetting to Idle *)
        TestingStatus := 0;
END_CASE;

END_FUNCTION_BLOCK