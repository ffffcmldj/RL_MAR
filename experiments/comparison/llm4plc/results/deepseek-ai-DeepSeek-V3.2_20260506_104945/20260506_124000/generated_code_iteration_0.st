START_ST
FUNCTION_BLOCK RoboticWeldingSystem
VAR_INPUT
    RobotArm1Ready : BOOL;
    RobotArm2Ready : BOOL;
    WeldingGunReady : BOOL;
    StartButton : BOOL;
    StopButton : BOOL;
END_VAR
VAR_OUTPUT
    WeldingTrigger : BOOL;
    WeldingComplete : BOOL;
END_VAR
VAR
    state : INT; (* 0 = IDLE, 1 = WELDING *)
END_VAR

(* State Machine Execution *)
CASE state OF
    0: (* IDLE State *)
        WeldingTrigger := FALSE;
        WeldingComplete := TRUE;
        (* Transition to WELDING state if all conditions are met *)
        IF (RobotArm1Ready AND RobotArm2Ready AND WeldingGunReady AND StartButton) THEN
            state := 1;
        END_IF;

    1: (* WELDING State *)
        WeldingTrigger := TRUE;
        WeldingComplete := FALSE;
        (* Transition to IDLE state if StopButton is pressed OR any readiness signal is lost *)
        IF (StopButton OR NOT RobotArm1Ready OR NOT RobotArm2Ready OR NOT WeldingGunReady) THEN
            state := 0;
        END_IF;
END_CASE;

END_FUNCTION_BLOCK
END_ST