START_ST
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

BEGIN
    (* Step A: State Transition Check *)
    
    (* Transition from STATE 0 (IDLE) to STATE 1 (TESTING) *)
    IF (TestingStatus = 0) AND (StartButton = TRUE) THEN
        TestingStatus := 1;
    END_IF;

    (* Transition from STATE 1 (TESTING) to STATE 2 (COMPLETED) *)
    IF (TestingStatus = 1) AND (SoilSampleDetected = TRUE) THEN
        IF (NutrientSensorValue >= NutrientThreshold) AND (pHSensorValue <= pHThreshold) THEN
            TestingStatus := 2;
        END_IF;
    END_IF;

    (* Step B: Sensor Simulation (Only if State is 1) *)
    IF (TestingStatus = 1) THEN
        (* Increment NutrientSensorValue by 0.1, cap at 0.9 *)
        NutrientSensorValue := NutrientSensorValue + 0.1;
        IF NutrientSensorValue > 0.9 THEN
            NutrientSensorValue := 0.9;
        END_IF;

        (* Decrement pHSensorValue by 0.5, floor at 4.0 *)
        pHSensorValue := pHSensorValue - 0.5;
        IF pHSensorValue < 4.0 THEN
            pHSensorValue := 4.0;
        END_IF;
    END_IF;

    (* Step C: Output Assignment *)
    CASE TestingStatus OF
        0: (* STATE 0: IDLE *)
            NutrientPump := FALSE;
            pHAdjustmentPump := FALSE;
            
        1: (* STATE 1: TESTING *)
            NutrientPump := TRUE;
            pHAdjustmentPump := TRUE;
            
        2: (* STATE 2: COMPLETED *)
            NutrientPump := FALSE;
            pHAdjustmentPump := FALSE;
            
        ELSE
            (* Fallback for unexpected states, though logic prevents this *)
            NutrientPump := FALSE;
            pHAdjustmentPump := FALSE;
        END_CASE;
END_FUNCTION_BLOCK
END_ST