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
    bAllReady : BOOL;         (* Internal flag for all components ready *)
END_VAR

(* Check if all components are ready *)
bAllReady := RobotArm1Ready AND RobotArm2Ready AND WeldingGunReady;

(* Main safety logic with stop button having highest priority *)
IF StopButton THEN
    (* Immediate stop when stop button is pressed *)
    WeldingTrigger := FALSE;
    WeldingComplete := TRUE;
ELSIF bAllReady AND StartButton THEN
    (* Start welding only when all components ready AND start button pressed *)
    WeldingTrigger := TRUE;
    WeldingComplete := FALSE;
ELSE
    (* Default state - no welding *)
    WeldingTrigger := FALSE;
    WeldingComplete := TRUE;
END_IF;

END_FUNCTION_BLOCK