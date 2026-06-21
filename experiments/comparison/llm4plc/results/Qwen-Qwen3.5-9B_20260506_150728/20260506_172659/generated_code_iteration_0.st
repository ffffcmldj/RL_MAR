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
    AllSystemsReady : BOOL; (* Intermediate variable to check if all systems are ready *)
END_VAR
END_VAR

(* Check if all required systems are ready *)
AllSystemsReady := RobotArm1Ready AND RobotArm2Ready AND WeldingGunReady;

(* Logic for WeldingTrigger:
   - Trigger only if all systems are ready AND StartButton is pressed
   - Reset to FALSE if StopButton is pressed
*)
IF AllSystemsReady AND StartButton THEN
    WeldingTrigger := TRUE;
ELSIF StopButton THEN
    WeldingTrigger := FALSE;
ELSE
    WeldingTrigger := FALSE;
END_IF;

(* Logic for WeldingComplete:
   - Set to TRUE if StopButton is pressed (immediate safety stop)
   - Set to TRUE if WeldingTrigger is FALSE (welding not active)
   - Note: If WeldingTrigger is TRUE, WeldingComplete remains FALSE until the process finishes externally.
*)
IF StopButton THEN
    WeldingComplete := TRUE;
ELSIF NOT WeldingTrigger THEN
    WeldingComplete := TRUE;
ELSE
    WeldingComplete := FALSE;
END_IF;

END_FUNCTION_BLOCK
END_ST