FUNCTION_BLOCK SushiConveyorControl
VAR_INPUT
    StartButton : BOOL;    (* Input to start the conveyor *)
    StopButton : BOOL;     (* Input to stop the conveyor *)
    EmergencyStop : BOOL;  (* Input for emergency stop *)
END_VAR
VAR_OUTPUT
    ConveyorMotor : BOOL;  (* Output to control the conveyor motor *)
END_VAR
VAR
    BeltRunning : BOOL;    (* Status of the conveyor: Running or Stopped *)
    ConveyorTimer : INT;   (* Timer counter for conveyor rotation *)
    RotationTime : INT := 5; (* Time for one rotation in seconds *)
    bFirstScan : BOOL := TRUE; (* First scan flag for initialization *)
END_VAR

(* Initialization on first scan *)
IF bFirstScan THEN
    BeltRunning := FALSE;
    ConveyorTimer := 0;
    ConveyorMotor := FALSE;
    bFirstScan := FALSE;
END_IF

(* Highest Priority Emergency Stop Handling *)
IF EmergencyStop THEN
    ConveyorMotor := FALSE;
    BeltRunning := FALSE;
    ConveyorTimer := 0;
    RETURN;  (* Immediate exit - highest priority *)
END_IF

(* Start/Stop Control Logic *)
IF StartButton AND NOT BeltRunning THEN
    (* Start condition *)
    ConveyorMotor := TRUE;
    BeltRunning := TRUE;
    ConveyorTimer := 0;
ELSIF StopButton AND BeltRunning THEN
    (* Stop condition *)
    ConveyorMotor := FALSE;
    BeltRunning := FALSE;
    ConveyorTimer := 0;
END_IF

(* Simulated Rotation Cycle *)
IF BeltRunning THEN
    (* Increment timer *)
    ConveyorTimer := ConveyorTimer + 1;
    
    (* Check if timer reached rotation time *)
    IF ConveyorTimer >= RotationTime THEN
        ConveyorTimer := 0;  (* Reset timer for next cycle *)
    END_IF
    
    (* Motor remains TRUE during running state *)
    ConveyorMotor := TRUE;
END_IF

END_FUNCTION_BLOCK