FUNCTION_BLOCK SushiConveyorControl
VAR_INPUT
    StartButton : BOOL; (* Input to start the conveyor *)
    StopButton : BOOL;  (* Input to stop the conveyor *)
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

(* Main control logic *)
IF EmergencyStop THEN
    ConveyorMotor := FALSE; (* Stop the conveyor motor *)
    BeltRunning := FALSE; (* Set running status to FALSE *)
    ConveyorTimer := 0; (* Reset the timer *)
    RETURN; (* Exit the function block immediately *)
END_IF;

IF StartButton AND NOT BeltRunning THEN
    ConveyorMotor := TRUE; (* Start the conveyor motor *)
    BeltRunning := TRUE; (* Set running status to TRUE *)
    ConveyorTimer := 0; (* Reset the timer *)
END_IF;

IF StopButton AND BeltRunning THEN
    ConveyorMotor := FALSE; (* Stop the conveyor motor *)
    BeltRunning := FALSE; (* Set running status to FALSE *)
    ConveyorTimer := 0; (* Reset the timer *)
END_IF;

(* Simulated rotation logic *)
IF BeltRunning THEN
    ConveyorTimer := ConveyorTimer + 1; (* Increment the timer by 1 second *)

    IF ConveyorTimer < RotationTime THEN
        ConveyorMotor := TRUE; (* Keep the motor running *)
    ELSIF ConveyorTimer >= RotationTime THEN
        ConveyorTimer := 0; (* Reset the timer *)
        ConveyorMotor := TRUE; (* Keep the motor running *)
    END_IF;
END_IF;

END_FUNCTION_BLOCK