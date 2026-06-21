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
    state : INT; (* Current state: 0=IDLE, 1=RUNNING, 2=EMERGENCY_STOPPED *)
    prevState : INT; (* Previous state for edge detection *)
    startRisingEdge : BOOL; (* Rising edge detection for StartButton *)
    stopRisingEdge : BOOL; (* Rising edge detection for StopButton *)
    prevStartButton : BOOL; (* Previous value of StartButton *)
    prevStopButton : BOOL; (* Previous value of StopButton *)
END_VAR

(* Initialization *)
IF NOT BeltRunning THEN
    BeltRunning := FALSE;
    ConveyorTimer := 0;
    state := 0;
    prevState := 0;
    startRisingEdge := FALSE;
    stopRisingEdge := FALSE;
    prevStartButton := FALSE;
    prevStopButton := FALSE;
END_IF;

(* Edge detection for buttons *)
startRisingEdge := StartButton AND NOT prevStartButton;
stopRisingEdge := StopButton AND NOT prevStopButton;
prevStartButton := StartButton;
prevStopButton := StopButton;

(* Emergency Stop - Highest Priority *)
IF EmergencyStop THEN
    state := 2;
END_IF;

(* State Machine *)
CASE state OF
    0: (* IDLE state *)
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
        
        (* Transitions from IDLE *)
        IF startRisingEdge AND NOT BeltRunning AND NOT EmergencyStop THEN
            state := 1;
        ELSIF EmergencyStop THEN
            state := 2;
        END_IF;
        
    1: (* RUNNING state *)
        ConveyorMotor := TRUE;
        BeltRunning := TRUE;
        
        (* Timer logic within RUNNING state *)
        ConveyorTimer := ConveyorTimer + 1; (* Increment timer each scan cycle *)
        IF ConveyorTimer >= RotationTime THEN
            ConveyorTimer := 0; (* Reset timer when reaching RotationTime *)
        END_IF;
        
        (* Transitions from RUNNING *)
        IF stopRisingEdge AND BeltRunning AND NOT EmergencyStop THEN
            state := 0;
        ELSIF EmergencyStop THEN
            state := 2;
        END_IF;
        
    2: (* EMERGENCY_STOPPED state *)
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
        
        (* Immediate exit as specified *)
        RETURN;
        
        (* Transitions from EMERGENCY_STOPPED *)
        (* Note: This code won't be reached due to RETURN, but included for completeness *)
        IF NOT EmergencyStop AND NOT StartButton AND NOT StopButton THEN
            state := 0;
        END_IF;
        
END_CASE;

(* Store previous state for next cycle *)
prevState := state;

END_FUNCTION_BLOCK
END_ST