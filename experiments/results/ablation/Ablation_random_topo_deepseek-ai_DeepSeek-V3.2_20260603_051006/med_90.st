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
    BeltRunning : BOOL := FALSE;     (* Status of the conveyor: Running or Stopped *)
    ConveyorTimer : INT := 0;        (* Timer counter for conveyor rotation *)
    RotationTime : INT := 5;         (* Time for one rotation in seconds *)
    TimerPreset : TIME := T#1S;      (* 1 second timer preset for counting *)
    TimerInstance : TON;             (* Timer function block instance *)
END_VAR

(* Emergency Stop - Highest Priority *)
IF EmergencyStop THEN
    ConveyorMotor := FALSE;
    BeltRunning := FALSE;
    ConveyorTimer := 0;
    TimerInstance(IN := FALSE, PT := T#0S);
    RETURN;
END_IF;

(* Start/Stop Control *)
IF StartButton AND NOT BeltRunning THEN
    ConveyorMotor := TRUE;
    BeltRunning := TRUE;
    ConveyorTimer := 0;
    TimerInstance(IN := FALSE, PT := T#0S);
END_IF;

IF StopButton AND BeltRunning THEN
    ConveyorMotor := FALSE;
    BeltRunning := FALSE;
    ConveyorTimer := 0;
    TimerInstance(IN := FALSE, PT := T#0S);
END_IF;

(* Simulated Rotation - Timed On/Off Cycle *)
IF BeltRunning THEN
    (* Start 1-second timer for counting *)
    TimerInstance(IN := TRUE, PT := TimerPreset);
    
    (* Increment timer every second *)
    IF TimerInstance.Q THEN
        ConveyorTimer := ConveyorTimer + 1;
        TimerInstance(IN := FALSE, PT := T#0S);
    END_IF;
    
    (* Reset timer when reaching RotationTime *)
    IF ConveyorTimer >= RotationTime THEN
        ConveyorTimer := 0;
    END_IF;
    
    (* Keep motor ON during entire cycle *)
    ConveyorMotor := TRUE;
ELSE
    (* Ensure motor is OFF when belt is not running *)
    ConveyorMotor := FALSE;
END_IF;

END_FUNCTION_BLOCK