START_REASON
The previous code failed due to an encoding error: `'gbk' codec can't decode byte 0xaf in position 111`. This indicates that the Structured Text (ST) code contained non-ASCII characters (likely Chinese comments like `(* 输入 ... *)`) that were not properly encoded in UTF-8 or were interpreted incorrectly by the toolchain expecting ASCII/GBK.

To fix this:
1.  **Remove all non-English comments**: Replace Chinese comments with English equivalents to ensure the code is pure ASCII/UTF-8 compatible.
2.  **Verify Syntax**: Ensure all statements end with semicolons (`;`) and control structures (`IF`, `END_IF`, `END_FUNCTION_BLOCK`) are correctly formatted.
3.  **Maintain Structure**: Keep the `FUNCTION_BLOCK` structure and `END_VAR` usage as required.

The specific error "replace 'IF' with ';'" from the previous turn was likely a cascading error caused by the encoding issue confusing the parser, or a strict requirement for the `END_FUNCTION_BLOCK` to have a terminating semicolon in this specific toolchain environment. I will ensure `END_FUNCTION_BLOCK` ends with a semicolon.
END_REASON
START_ST
FUNCTION_BLOCK SushiConveyorControl
VAR_INPUT
    StartButton : BOOL;
    StopButton : BOOL;
    EmergencyStop : BOOL;
END_VAR
VAR_OUTPUT
    ConveyorMotor : BOOL;
END_VAR
VAR
    BeltRunning : BOOL;
    ConveyorTimer : INT;
    RotationTime : INT := 5;
END_VAR;

BEGIN
    (* STEP 1: EMERGENCY STOP *)
    IF EmergencyStop THEN
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
        RETURN;
    END_IF;

    (* STEP 2: START CONTROL *)
    IF StartButton AND NOT BeltRunning THEN
        ConveyorMotor := TRUE;
        BeltRunning := TRUE;
        ConveyorTimer := 0;
    END_IF;

    (* STEP 3: STOP CONTROL *)
    IF StopButton AND BeltRunning THEN
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
    END_IF;

    (* STEP 4: SIMULATED ROTATION *)
    IF BeltRunning THEN
        ConveyorTimer := ConveyorTimer + 1;

        IF ConveyorTimer >= RotationTime THEN
            ConveyorMotor := FALSE;
            BeltRunning := FALSE;
            ConveyorTimer := 0;
        END_IF;
    END_IF;

END_FUNCTION_BLOCK;
END_ST
END_REASON