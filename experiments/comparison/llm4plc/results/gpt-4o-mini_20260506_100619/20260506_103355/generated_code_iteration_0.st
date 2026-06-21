ructured-text
START_ST
FUNCTION_BLOCK RoboticWeldingSystem
VAR_INPUT
    RobotArm1Ready : BOOL; (* Input for robot arm 1 ready status *)
    RobotArm2Ready : BOOL; (* Input for robot arm 2 ready status *)
    WeldingGunReady : BOOL; (* Input for welding gun ready status *)
    StartButton : BOOL; (* Input for start button press *)
    StopButton : BOOL; (* Input for stop button press *)
END_VAR

VAR_OUTPUT
    WeldingTrigger : BOOL; (* Output to trigger welding *)
    WeldingComplete : BOOL; (* Output indicating welding completion *)
END_VAR

VAR
    state : INT; (* The state variable *)
    prevState : INT; (* The previous state variable *)
END_VAR

(* State Definitions *)
CONST
    STATE_INITIALIZE : INT := 0;
    STATE_WAITING : INT := 1;
    STATE_WELDING : INT := 2;
    STATE_SAFETY_STOP : INT := 3;
END_CONST

(* Initialization *)
state := STATE_INITIALIZE;
WeldingTrigger := FALSE;
WeldingComplete := FALSE;

(* State Machine Logic *)
CASE state OF
    STATE_INITIALIZE:
        state := STATE_WAITING;

    STATE_WAITING:
        WeldingTrigger := FALSE;
        WeldingComplete := FALSE;
        IF (RobotArm1Ready AND RobotArm2Ready AND WeldingGunReady AND StartButton) THEN
            state := STATE_WELDING;
        ELSIF StopButton THEN
            state := STATE_SAFETY_STOP;

    STATE_WELDING:
        WeldingTrigger := TRUE;
        WeldingComplete := FALSE;
        IF StopButton THEN
            state := STATE_SAFETY_STOP;
        ELSIF NOT WeldingTrigger THEN
            state := STATE_WAITING;

    STATE_SAFETY_STOP:
        WeldingTrigger := FALSE;
        WeldingComplete := TRUE;
        IF NOT StopButton AND (RobotArm1Ready AND RobotArm2Ready AND WeldingGunReady AND StartButton) THEN
            state := STATE_WAITING;
END_CASE;

END_FUNCTION_BLOCK
END_ST