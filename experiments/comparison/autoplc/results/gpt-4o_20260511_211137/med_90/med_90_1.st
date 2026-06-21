FUNCTION_BLOCK SushiConveyorControl
    VAR_INPUT
        StartButton : BOOL; (* Input to start the conveyor *)
        StopButton : BOOL; (* Input to stop the conveyor *)
        EmergencyStop : BOOL; (* Input for emergency stop *)
    END_VAR
    VAR_OUTPUT
        ConveyorMotor : BOOL; (* Output to control the conveyor motor *)
    END_VAR
    VAR
        BeltRunning : BOOL := FALSE; (* Status of the conveyor: Running or Stopped *)
        ConveyorTimer : INT := 0; (* Timer counter for conveyor rotation *)
        RotationTime : INT := 5; (* Time for one rotation in seconds *)
    END_VAR

    // Emergency Stop Logic
    IF EmergencyStop THEN
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
        RETURN; // Exit immediately for emergency stop
    END_IF

    // Start Control Logic
    IF StartButton AND NOT BeltRunning THEN
        ConveyorMotor := TRUE;
        BeltRunning := TRUE;
        ConveyorTimer := 0;
    END_IF

    // Stop Control Logic
    IF StopButton AND BeltRunning THEN
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
    END_IF

    // Simulated Rotation Logic
    IF BeltRunning THEN
        ConveyorTimer := ConveyorTimer + 1;
        IF ConveyorTimer >= RotationTime THEN
            ConveyorTimer := 0; // Reset timer after reaching rotation time
        END_IF
        ConveyorMotor := TRUE; // Keep motor running during the cycle
    END_IF

END_FUNCTION_BLOCK