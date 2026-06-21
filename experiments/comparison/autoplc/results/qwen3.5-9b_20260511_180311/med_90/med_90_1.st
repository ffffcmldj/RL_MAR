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
    i : INT;
END_VAR

BeltRunning := FALSE;
ConveyorTimer := 0;

IF EmergencyStop THEN
    ConveyorMotor := FALSE;
    BeltRunning := FALSE;
    ConveyorTimer := 0;
    RETURN;
END_IF;

IF StartButton AND NOT BeltRunning THEN
    ConveyorMotor := TRUE;
    BeltRunning := TRUE;
    ConveyorTimer := 0;
ELSIF StopButton AND BeltRunning THEN
    ConveyorMotor := FALSE;
    BeltRunning := FALSE;
    ConveyorTimer := 0;
ELSIF BeltRunning THEN
    ConveyorMotor := TRUE;
    ConveyorTimer := ConveyorTimer + 1;
    IF ConveyorTimer >= RotationTime THEN
        ConveyorTimer := 0;
    END_IF;
END_IF;

END_FUNCTION_BLOCK