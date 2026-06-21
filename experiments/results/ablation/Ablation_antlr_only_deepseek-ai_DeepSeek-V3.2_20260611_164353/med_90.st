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
    tonTimer : TON;        (* Timer function block for precise timing *)
END_VAR

(* Initialization *)
BeltRunning := FALSE;
ConveyorTimer := 0;

(* Emergency Stop - Highest Priority *)
IF EmergencyStop THEN
    ConveyorMotor := FALSE;
    BeltRunning := FALSE;
    ConveyorTimer := 0;
    tonTimer(IN := FALSE, PT := T#0S);
    RETURN;
END_IF;

(* Start/Stop Control with priority to Stop *)
IF StopButton AND BeltRunning THEN
    ConveyorMotor := FALSE;
    BeltRunning := FALSE;
    ConveyorTimer := 0;
    tonTimer(IN := FALSE, PT := T#0S);
ELSIF StartButton AND NOT BeltRunning AND NOT StopButton THEN
    ConveyorMotor := TRUE;
    BeltRunning := TRUE;
    ConveyorTimer := 0;
    tonTimer(IN := FALSE, PT := T#0S);
END_IF;

(* Simulated Rotation - Timer-based cycle *)
IF BeltRunning THEN
    (* Use TON timer for precise timing *)
    tonTimer(IN := TRUE, PT := T#1S);
    
    IF tonTimer.Q THEN
        ConveyorTimer := ConveyorTimer + 1;
        tonTimer(IN := FALSE, PT := T#0S);
        
        (* Check if rotation time reached *)
        IF ConveyorTimer >= RotationTime THEN
            ConveyorTimer := 0;
        END_IF;
    END_IF;
    
    (* Keep motor running while belt is running *)
    ConveyorMotor := TRUE;
END_IF;

END_FUNCTION_BLOCK