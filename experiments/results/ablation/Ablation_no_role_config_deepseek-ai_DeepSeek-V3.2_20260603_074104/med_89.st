FUNCTION_BLOCK SoilTestingDeviceControl
VAR_INPUT
    StartButton : BOOL;           (* Input for starting the testing process *)
    SoilSampleDetected : BOOL;    (* Input for detecting soil sample *)
END_VAR
VAR_OUTPUT
    NutrientPump : BOOL;          (* Output to control nutrient pump *)
    pHAdjustmentPump : BOOL;      (* Output to control pH adjustment pump *)
END_VAR
VAR
    pHSensorValue : REAL;         (* Simulated pH sensor value *)
    NutrientSensorValue : REAL;   (* Simulated nutrient sensor value *)
    TestingStatus : INT;          (* Status: 0=Idle, 1=Testing, 2=Completed *)
    NutrientThreshold : REAL := 0.7;  (* Nutrient level threshold for analysis *)
    pHThreshold : REAL := 6.5;        (* pH level threshold for analysis *)
END_VAR

(* Main state machine logic *)
CASE TestingStatus OF
    0: (* Idle state *)
        (* Initialize sensor values *)
        pHSensorValue := 7.0;
        NutrientSensorValue := 0.5;
        
        (* Ensure pumps are off in idle state *)
        NutrientPump := FALSE;
        pHAdjustmentPump := FALSE;
        
        (* Transition to Testing state when StartButton is pressed *)
        IF StartButton THEN
            TestingStatus := 1;
        END_IF;
        
    1: (* Testing state *)
        (* Activate both pumps during testing *)
        NutrientPump := TRUE;
        pHAdjustmentPump := TRUE;
        
        (* Update simulated sensor values with limits *)
        NutrientSensorValue := LIMIT(0.5, NutrientSensorValue + 0.1, 0.9);
        pHSensorValue := LIMIT(4.0, pHSensorValue - 0.5, 7.0);
        
        (* Check for sample detection and threshold conditions *)
        IF SoilSampleDetected THEN
            IF (NutrientSensorValue >= NutrientThreshold) AND (pHSensorValue <= pHThreshold) THEN
                TestingStatus := 2;  (* Transition to Completed state *)
            END_IF;
        END_IF;
        
    2: (* Completed state *)
        (* Deactivate pumps when testing is complete *)
        NutrientPump := FALSE;
        pHAdjustmentPump := FALSE;
        
        (* Optionally: Add logic to reset to idle state if needed *)
        (* IF ResetCondition THEN TestingStatus := 0; END_IF *)
        
END_CASE;

END_FUNCTION_BLOCK