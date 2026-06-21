iec61131-3
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
    BeltRunning : BOOL := FALSE; (* Status of the conveyor: Running or Stopped *)
    ConveyorTimer : INT := 0; (* Timer counter for conveyor rotation *)
    RotationTime : INT := 5; (* Time for one rotation in seconds *)
    state : INT := 0; (* Current state of the FSM *)
    prevState : INT := -1; (* Previous state for tracking transitions *)
END_VAR

(* Main logic *)
IF EmergencyStop THEN
    (* STATE 1: Emergency Stop *)
    ConveyorMotor := FALSE;
    BeltRunning := FALSE;
    ConveyorTimer := 0;
    state := 1;
    RETURN;
END_IF

CASE state OF
    0: (* STATE 0: Initialize *)
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
        IF StartButton AND NOT BeltRunning THEN
            state := 2; (* Transition to STATE 2: Start Conveyor *)
        END_IF

    1: (* STATE 1: Emergency Stop *)
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
        IF NOT EmergencyStop THEN
            state := 0; (* Transition back to STATE 0: Initialize *)
        END_IF

    2: (* STATE 2: Start Conveyor *)
        ConveyorMotor := TRUE;
        BeltRunning := TRUE;
        ConveyorTimer := 0;
        IF EmergencyStop THEN
            state := 1; (* Transition to STATE 1: Emergency Stop *)
        ELSIF BeltRunning THEN
            state := 4; (* Transition to STATE 4: Simulated Rotation *)
        END_IF

    3: (* STATE 3: Stop Conveyor *)
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
        IF EmergencyStop THEN
            state := 1; (* Transition to STATE 1: Emergency Stop *)
        ELSE
            state := 0; (* Transition back to STATE 0: Initialize *)
        END_IF

    4: (* STATE 4: Simulated Rotation *)
        IF ConveyorTimer < RotationTime THEN
            ConveyorMotor := TRUE;
            ConveyorTimer := ConveyorTimer + 1; (* Increment timer *)
        ELSE
            ConveyorTimer := 0; (* Reset timer *)
        END_IF

        IF EmergencyStop THEN
            state := 1; (* Transition to STATE 1: Emergency Stop *)
        ELSIF StopButton AND BeltRunning THEN
            state := 3; (* Transition to STATE 3: Stop Conveyor *)
        END_IF

END_CASE

END_FUNCTION_BLOCK
END_ST