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
    tSampleVerification : TON; (* Timer for sample verification delay *)
    bStartButtonPrev : BOOL; (* Edge detection for StartButton *)
    bSampleDetectedPrev : BOOL; (* Edge detection for SoilSampleDetected *)
END_VAR

(* State Machine Implementation *)
CASE TestingStatus OF
    0: (* Idle State *)
        (* Initialize sensor values *)
        pHSensorValue := 7.0;
        NutrientSensorValue := 0.5;
        
        (* Ensure pumps are deactivated *)
        NutrientPump := FALSE;
        pHAdjustmentPump := FALSE;
        
        (* Reset verification timer *)
        tSampleVerification(IN:=FALSE, PT:=T#2S);
        
        (* Detect rising edge of StartButton to transition to Testing state *)
        IF StartButton AND NOT bStartButtonPrev THEN
            TestingStatus := 1;
            (* Activate pumps upon transition *)
            NutrientPump := TRUE;
            pHAdjustmentPump := TRUE;
        END_IF;
        
        (* Store current button state for next cycle *)
        bStartButtonPrev := StartButton;
        
    1: (* Testing State *)
        (* Update sensor values with limits *)
        NutrientSensorValue := REAL_MIN(NutrientSensorValue + 0.1, 0.9);
        pHSensorValue := REAL_MAX(pHSensorValue - 0.5, 4.0);
        
        (* Detect rising edge of SoilSampleDetected *)
        IF SoilSampleDetected AND NOT bSampleDetectedPrev THEN
            (* Start verification timer *)
            tSampleVerification(IN:=TRUE, PT:=T#2S);
        END_IF;
        
        (* Check for completion conditions after verification delay *)
        IF tSampleVerification.Q THEN
            IF (NutrientSensorValue >= NutrientThreshold) AND (pHSensorValue <= pHThreshold) THEN
                (* Conditions met - transition to Completed *)
                TestingStatus := 2;
                NutrientPump := FALSE;
                pHAdjustmentPump := FALSE;
            ELSE
                (* Conditions not met - reset timer for next detection *)
                tSampleVerification(IN:=FALSE);
            END_IF;
        END_IF;
        
        (* Store current sample detection state for next cycle *)
        bSampleDetectedPrev := SoilSampleDetected;
        
    2: (* Completed State *)
        (* Ensure pumps remain deactivated *)
        NutrientPump := FALSE;
        pHAdjustmentPump := FALSE;
        
        (* Reset timer *)
        tSampleVerification(IN:=FALSE, PT:=T#2S);
        
        (* Reset to Idle when StartButton is released *)
        IF NOT StartButton THEN
            TestingStatus := 0;
        END_IF;
        
END_CASE;

END_FUNCTION_BLOCK