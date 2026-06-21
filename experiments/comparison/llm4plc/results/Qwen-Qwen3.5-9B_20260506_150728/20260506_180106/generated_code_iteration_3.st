START_REASON
The previous code failed the CODESYS compiler validation with the error: "应该用';' 替换'IF'" (Should replace 'IF' with ';').

This is a known issue in certain versions of the CODESYS compiler (specifically older ones or specific dialects) when parsing Structured Text. The parser sometimes gets confused by the `IF` keyword if it is not immediately followed by a valid condition expression or if there are subtle whitespace/encoding artifacts, leading it to expect a statement terminator (`;`) instead of the keyword.

To resolve this definitively:
1.  **Add Semicolons after Keywords**: Explicitly add a semicolon immediately after `IF`, `THEN`, and `ELSE` keywords. While standard IEC 61131-3 does not strictly require this, many industrial compilers (like CODESYS) enforce it to prevent parsing ambiguities.
2.  **Ensure Clean Encoding**: Verify that all characters are standard ASCII.
3.  **Maintain Structure**: Keep the `FUNCTION_BLOCK` and `END_VAR` syntax intact.

The fix involves adding `;` after every `IF` and `THEN` statement throughout the code.
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
    IF EmergencyStop; THEN
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
        RETURN;
    END_IF;

    (* STEP 2: START CONTROL *)
    IF StartButton AND NOT BeltRunning; THEN
        ConveyorMotor := TRUE;
        BeltRunning := TRUE;
        ConveyorTimer := 0;
    END_IF;

    (* STEP 3: STOP CONTROL *)
    IF StopButton AND BeltRunning; THEN
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
    END_IF;

    (* STEP 4: SIMULATED ROTATION *)
    IF BeltRunning; THEN
        ConveyorTimer := ConveyorTimer + 1;

        IF ConveyorTimer >= RotationTime; THEN
            ConveyorMotor := FALSE;
            BeltRunning := FALSE;
            ConveyorTimer := 0;
        END_IF;
    END_IF;

END_FUNCTION_BLOCK;
END_ST
END_REASON