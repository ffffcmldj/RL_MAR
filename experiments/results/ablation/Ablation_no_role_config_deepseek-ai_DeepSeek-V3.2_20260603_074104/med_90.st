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
    PrevStartButton : BOOL; (* Previous state of StartButton for edge detection *)
    PrevStopButton : BOOL;  (* Previous state of StopButton for edge detection *)
END_VAR

(* Initialization *)
BeltRunning := FALSE;
ConveyorMotor := FALSE;
ConveyorTimer := 0;
PrevStartButton := FALSE;
PrevStopButton := FALSE;

(* Emergency Stop - Highest Priority *)
IF EmergencyStop THEN
    ConveyorMotor := FALSE;
    BeltRunning := FALSE;
    ConveyorTimer := 0;
    RETURN;
END_IF;

(* Start/Stop Control with edge detection *)
IF StartButton AND NOT PrevStartButton AND NOT BeltRunning THEN
    (* Rising edge detected on StartButton when conveyor is stopped *)
    ConveyorMotor := TRUE;
    BeltRunning := TRUE;
    ConveyorTimer := 0;
ELSIF StopButton AND NOT PrevStopButton AND BeltRunning THEN
    (* Rising edge detected on StopButton when conveyor is running *)
    ConveyorMotor := FALSE;
    BeltRunning := FALSE;
    ConveyorTimer := 0;
END_IF;

(* Simulated Rotation (Timed On/Off Cycle) *)
IF BeltRunning THEN
    (* Increment timer each scan cycle when running *)
    ConveyorTimer := ConveyorTimer + 1;
    
    (* Check if timer has reached rotation time *)
    IF ConveyorTimer >= RotationTime THEN
        ConveyorTimer := 0;  (* Reset timer for next cycle *)
        (* For on/off cycle simulation, toggle motor state *)
        ConveyorMotor := NOT ConveyorMotor;
    END_IF;
ELSE
    (* Ensure motor is off when not running *)
    ConveyorMotor := FALSE;
END_IF;

(* Store current button states for next edge detection *)
PrevStartButton := StartButton;
PrevStopButton := StopButton;

END_FUNCTION_BLOCK