START_REASON
The error "发现非预期的记号'END_VAR'" (Unexpected token 'END_VAR') occurs because the code contains two consecutive `END_VAR` statements. In IEC 61131-3 Structured Text, `END_VAR` is used to close a variable section (VAR, VAR_INPUT, VAR_OUTPUT, VAR_IN_OUT, VAR_TEMP). It should only appear once at the end of the variable declaration block. The original code incorrectly placed a second `END_VAR` immediately after the `VAR` section, before the logic statements begin. This second `END_VAR` was likely a typo or a misunderstanding of the syntax, causing the compiler to expect a statement or another block type instead of finding an immediate terminator. The fix involves removing the duplicate `END_VAR` line so that the variable section closes correctly before the executable logic begins.
END_REASON

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