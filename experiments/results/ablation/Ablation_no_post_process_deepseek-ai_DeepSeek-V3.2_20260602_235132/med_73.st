FUNCTION_BLOCK RoboticWeldingSystem
VAR_INPUT
    RobotArm1Ready : BOOL;    (* Input for robot arm 1 ready status *)
    RobotArm2Ready : BOOL;    (* Input for robot arm 2 ready status *)
    WeldingGunReady : BOOL;   (* Input for welding gun ready status *)
    StartButton : BOOL;       (* Input for start button press *)
    StopButton : BOOL;        (* Input for stop button press *)
END_VAR

VAR_OUTPUT
    WeldingTrigger : BOOL;    (* Output to trigger welding *)
    WeldingComplete : BOOL;   (* Output indicating welding completion *)
END_VAR

VAR
    bAllReady : BOOL;         (* Internal flag for all ready signals *)
    bStartCondition : BOOL;   (* Internal flag for valid start condition *)
END_VAR

(* Main logic for welding control *)
bAllReady := RobotArm1Ready AND RobotArm2Ready AND WeldingGunReady;
bStartCondition := bAllReady AND StartButton;

(* Priority: Stop button has highest precedence *)
IF StopButton THEN
    (* Safety stop: immediately halt welding and indicate completion *)
    WeldingTrigger := FALSE;
    WeldingComplete := TRUE;
ELSIF bStartCondition THEN
    (* Valid start condition: begin welding *)
    WeldingTrigger := TRUE;
    WeldingComplete := FALSE;
ELSE
    (* Default state: no welding, process complete *)
    WeldingTrigger := FALSE;
    WeldingComplete := TRUE;
END_IF;

END_FUNCTION_BLOCK