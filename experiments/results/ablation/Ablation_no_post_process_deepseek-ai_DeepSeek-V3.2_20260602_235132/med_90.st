(*
    FUNCTION_BLOCK: SushiConveyorControl
    Description: Controls an automated sushi conveyor belt with emergency stop, start/stop, and simulated rotation via timed on/off cycles.
    Priority: Emergency Stop (highest) > Start/Stop Control > Simulated Rotation.
    Note: This implementation uses a simple integer counter (ConveyorTimer) for timing. In a real PLC, this would typically be replaced by a hardware timer (TON) or a time-based increment.
*)

FUNCTION_BLOCK SushiConveyorControl
VAR_INPUT
    StartButton : BOOL;     (* Momentary input to start the conveyor *)
    StopButton : BOOL;      (* Momentary input to stop the conveyor *)
    EmergencyStop : BOOL;   (* Hardwired emergency stop signal *)
END_VAR

VAR_OUTPUT
    ConveyorMotor : BOOL;   (* Output signal to the conveyor motor contactor *)
END_VAR

VAR
    BeltRunning : BOOL;     (* Internal state: TRUE when conveyor is running *)
    ConveyorTimer : INT;    (* Counter for simulated rotation timing *)
    RotationTime : INT := 5; (* Duration of one motor ON cycle (e.g., seconds) *)
    CycleActive : BOOL;     (* Internal flag: TRUE during the ON part of the cycle *)
END_VAR

(* Main Logic Execution *)
BEGIN
    (* 1. EMERGENCY STOP - HIGHEST PRIORITY *)
    IF EmergencyStop THEN
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
        CycleActive := FALSE;
        RETURN; (* Immediate exit from the function block *)
    END_IF;

    (* 2. START/STOP CONTROL *)
    IF StartButton AND NOT BeltRunning THEN
        BeltRunning := TRUE;
        ConveyorTimer := 0;
        CycleActive := TRUE;
    ELSIF StopButton AND BeltRunning THEN
        BeltRunning := FALSE;
        ConveyorTimer := 0;
        CycleActive := FALSE;
        ConveyorMotor := FALSE;
    END_IF;

    (* 3. SIMULATED ROTATION (Timed On/Off Cycle) *)
    IF BeltRunning THEN
        (* Increment the timer to simulate passage of time *)
        ConveyorTimer := ConveyorTimer + 1;

        (* Check if the ON cycle duration has been reached *)
        IF ConveyorTimer >= RotationTime THEN
            ConveyorTimer := 0;       (* Reset timer for next cycle *)
            CycleActive := NOT CycleActive; (* Toggle between ON and OFF parts of the cycle *)
        END_IF;

        (* Motor is only energized during the active part of the cycle *)
        ConveyorMotor := CycleActive;
    ELSE
        (* Conveyor is not running, ensure motor is off and timer is reset *)
        ConveyorTimer := 0;
        CycleActive := FALSE;
        ConveyorMotor := FALSE;
    END_IF;

END_FUNCTION_BLOCK