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
    AllReady : BOOL;
END_VAR

    AllReady := RobotArm1Ready AND RobotArm2Ready AND WeldingGunReady AND StartButton;

    IF StopButton THEN
        WeldingTrigger := FALSE;
        WeldingComplete := TRUE;
    ELSE
        WeldingTrigger := AllReady;
        IF AllReady THEN
            WeldingComplete := FALSE;
        ELSE
            WeldingComplete := TRUE;
        END_IF;
    END_IF;

END_FUNCTION_BLOCK