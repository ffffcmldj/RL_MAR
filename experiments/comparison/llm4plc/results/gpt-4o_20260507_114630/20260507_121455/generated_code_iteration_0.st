plaintext
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
    state : INT := 0; (* Current state of the system *)
    prevState : INT := 0; (* Previous state of the system *)
    weldingCompleteSignal : BOOL := FALSE; (* Internal signal for welding completion *)
END_VAR

(* Finite State Machine Logic *)
IF StopButton THEN
    (* Transition to STATE 2: SAFETY_STOP *)
    prevState := state;
    state := 2;
END_IF

CASE state OF
    (* STATE 0: IDLE *)
    0:
        WeldingTrigger := FALSE;
        WeldingComplete := TRUE;
        
        (* Transition to STATE 1: WELDING *)
        IF RobotArm1Ready AND RobotArm2Ready AND WeldingGunReady AND StartButton THEN
            prevState := state;
            state := 1;
        END_IF;

    (* STATE 1: WELDING *)
    1:
        WeldingTrigger := TRUE;
        WeldingComplete := FALSE;

        (* Transition to STATE 2: SAFETY_STOP *)
        IF StopButton THEN
            prevState := state;
            state := 2;
        END_IF;

        (* Transition to STATE 3: WELDING_COMPLETE *)
        IF weldingCompleteSignal THEN
            prevState := state;
            state := 3;
        END_IF;

    (* STATE 2: SAFETY_STOP *)
    2:
        WeldingTrigger := FALSE;
        WeldingComplete := TRUE;

        (* Transition to STATE 0: IDLE *)
        IF NOT StopButton THEN
            prevState := state;
            state := 0;
        END_IF;

    (* STATE 3: WELDING_COMPLETE *)
    3:
        WeldingTrigger := FALSE;
        WeldingComplete := TRUE;

        (* Transition to STATE 0: IDLE *)
        IF NOT StartButton THEN
            prevState := state;
            state := 0;
        END_IF;

    (* Default case to handle unexpected states *)
    ELSE
        (* Reset to STATE 0: IDLE *)
        state := 0;
END_CASE;

(* Simulate welding completion signal for demonstration purposes *)
IF state = 1 THEN
    (* Simulate welding completion after some condition, e.g., a timer or external signal *)
    weldingCompleteSignal := TRUE; (* Replace this with actual completion logic *)
ELSE
    weldingCompleteSignal := FALSE;
END_IF;

END_FUNCTION_BLOCK
END_ST