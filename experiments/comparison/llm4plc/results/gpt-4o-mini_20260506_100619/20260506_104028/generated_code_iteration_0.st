ructured-text
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
    BeltRunning : BOOL; (* Status of the conveyor: Running or Stopped *)
    ConveyorTimer : INT; (* Timer counter for conveyor rotation *)
    RotationTime : INT := 5; (* Time for one rotation in seconds *)
    state : INT; (* The state variable *)
END_VAR

(* State Definitions *)
(* 0: INITIALIZE *)
(* 1: EMERGENCY STOP *)
(* 2: START CONVEYOR *)
(* 3: STOP CONVEYOR *)
(* 4: RUNNING CONVEYOR *)

(* Initialization *)
IF NOT BeltRunning THEN
    ConveyorMotor := FALSE;
    ConveyorTimer := 0;
    state := 0; (* Set initial state *)
END_IF

(* State Machine Logic *)
CASE state OF
    0: (* INITIALIZE *)
        IF EmergencyStop THEN
            state := 1; (* Transition to EMERGENCY STOP *)
        ELSIF StartButton AND NOT BeltRunning THEN
            state := 2; (* Transition to START CONVEYOR *)
        END_IF

    1: (* EMERGENCY STOP *)
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
        (* No transition, emergency stop is a high priority *)

    2: (* START CONVEYOR *)
        ConveyorMotor := TRUE;
        BeltRunning := TRUE;
        ConveyorTimer := 0;
        state := 4; (* Transition to RUNNING CONVEYOR *)

    3: (* STOP CONVEYOR *)
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
        state := 0; (* Reset to INITIALIZE state *)

    4: (* RUNNING CONVEYOR *)
        IF BeltRunning THEN
            IF ConveyorTimer < RotationTime THEN
                ConveyorMotor := TRUE; (* Keep motor running *)
                ConveyorTimer := ConveyorTimer + 1; (* Increment timer *)
            ELSE
                ConveyorTimer := 0; (* Reset timer *)
            END_IF
        END_IF

        IF StopButton AND BeltRunning THEN
            state := 3; (* Transition to STOP CONVEYOR *)
        END_IF
END_CASE

END_FUNCTION_BLOCK