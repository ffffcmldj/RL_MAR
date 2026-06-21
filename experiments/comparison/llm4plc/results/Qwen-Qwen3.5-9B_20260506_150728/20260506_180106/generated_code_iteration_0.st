START_ST
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
    BeltRunning : BOOL; (* Status of the conveyor: Running or Stopped *)
    ConveyorTimer : INT; (* Timer counter for conveyor rotation *)
    RotationTime : INT := 5; (* Time for one rotation in seconds *)
END_VAR

BEGIN
    (* ----------------------------------------------------------- *)
    (* STEP 1: EMERGENCY STOP (HIGHEST PRIORITY)                   *)
    (* If EmergencyStop is TRUE, halt everything immediately.      *)
    (* ----------------------------------------------------------- *)
    IF EmergencyStop THEN
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
        RETURN; (* Exit the function block immediately *)
    END_IF;

    (* ----------------------------------------------------------- *)
    (* STEP 2: START CONTROL                                       *)
    (* Start if button is pressed and conveyor is not running.     *)
    (* ----------------------------------------------------------- *)
    IF StartButton AND NOT BeltRunning THEN
        ConveyorMotor := TRUE;
        BeltRunning := TRUE;
        ConveyorTimer := 0;
    END_IF;

    (* ----------------------------------------------------------- *)
    (* STEP 3: STOP CONTROL                                         *)
    (* Stop if button is pressed and conveyor is currently running. *)
    (* ----------------------------------------------------------- *)
    IF StopButton AND BeltRunning THEN
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
    END_IF;

    (* ----------------------------------------------------------- *)
    (* STEP 4: SIMULATED ROTATION (TIMED ON/OFF CYCLE)              *)
    (* Logic executes only if the conveyor is running.             *)
    (* ----------------------------------------------------------- *)
    IF BeltRunning THEN
        (* Increment the timer *)
        ConveyorTimer := ConveyorTimer + 1;

        (* Check if the timer has reached the rotation limit *)
        IF ConveyorTimer >= RotationTime THEN
            (* Cycle Complete: Turn off motor and reset state *)
            ConveyorMotor := FALSE;
            BeltRunning := FALSE;
            ConveyorTimer := 0;
        END_IF;
        (* Else: Timer < RotationTime, ConveyorMotor remains TRUE *)
    END_IF;

END_FUNCTION_BLOCK
END_ST