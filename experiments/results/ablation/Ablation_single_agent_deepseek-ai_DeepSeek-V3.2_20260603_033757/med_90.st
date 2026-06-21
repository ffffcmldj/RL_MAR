FUNCTION_BLOCK SushiConveyorControl
VAR_INPUT
    StartButton : BOOL;     (* Input to start the conveyor *)
    StopButton : BOOL;      (* Input to stop the conveyor *)
    EmergencyStop : BOOL;   (* Input for emergency stop *)
END_VAR
VAR_OUTPUT
    ConveyorMotor : BOOL;   (* Output to control the conveyor motor *)
END_VAR
VAR
    BeltRunning : BOOL;     (* Status of the conveyor: Running or Stopped *)
    ConveyorTimer : INT;    (* Timer counter for conveyor rotation *)
    RotationTime : INT := 5; (* Time for one rotation in seconds *)
END_VAR

(* Emergency Stop - Highest Priority *)
IF EmergencyStop THEN
    ConveyorMotor := FALSE;
    BeltRunning := FALSE;
    ConveyorTimer := 0;
    RETURN;
END_IF;

(* Start/Stop Control *)
IF StartButton AND NOT BeltRunning THEN
    ConveyorMotor := TRUE;
    BeltRunning := TRUE;
    ConveyorTimer := 0;
ELSIF StopButton AND BeltRunning THEN
    ConveyorMotor := FALSE;
    BeltRunning := FALSE;
    ConveyorTimer := 0;
END_IF;

(* Simulated Rotation Cycle *)
IF BeltRunning THEN
    ConveyorTimer := ConveyorTimer + 1;
    IF ConveyorTimer >= RotationTime THEN
        ConveyorTimer := 0;
    END_IF;
    ConveyorMotor := TRUE;
END_IF;

END_FUNCTION_BLOCK