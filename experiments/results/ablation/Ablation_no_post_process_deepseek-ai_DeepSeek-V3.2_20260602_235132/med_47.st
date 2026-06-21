FUNCTION_BLOCK WindowCleaningSystem
VAR_INPUT
    StartButton : BOOL;
    EmergencyStop : BOOL;
    UpperLimit : BOOL;
    LowerLimit : BOOL;
END_VAR

VAR_OUTPUT
    ElevatorUp : BOOL;
    ElevatorDown : BOOL;
    RotateClockwise : BOOL;
    WaterPump : BOOL;
END_VAR

VAR
    CleaningInProgress : BOOL;
    AtUpperLimitLatch : BOOL;
    StartRisingEdge : R_TRIG;
END_VAR

(* Emergency Stop has absolute highest priority *)
IF EmergencyStop THEN
    CleaningInProgress := FALSE;
    AtUpperLimitLatch := FALSE;
    ElevatorUp := FALSE;
    ElevatorDown := FALSE;
    RotateClockwise := FALSE;
    WaterPump := FALSE;
    RETURN; (* Exit immediately to prevent any further logic execution *)
END_IF;

(* Detect rising edge of StartButton for safe initiation *)
StartRisingEdge(CLK := StartButton);

(* State transition logic *)
IF NOT CleaningInProgress THEN
    (* Idle state - waiting for valid start command *)
    IF StartRisingEdge.Q AND NOT UpperLimit AND LowerLimit THEN
        CleaningInProgress := TRUE;
        AtUpperLimitLatch := FALSE;
    END_IF;
ELSE
    (* Active cleaning cycle *)
    IF NOT AtUpperLimitLatch THEN
        (* Phase 1: Moving Up *)
        IF UpperLimit THEN
            AtUpperLimitLatch := TRUE;
        END_IF;
    ELSE
        (* Phase 2: Cleaning while Moving Down *)
        IF LowerLimit THEN
            CleaningInProgress := FALSE;
            AtUpperLimitLatch := FALSE;
        END_IF;
    END_IF;
END_IF;

(* Output logic with explicit mutual exclusion and safety interlocks *)
ElevatorUp := CleaningInProgress AND NOT AtUpperLimitLatch AND NOT UpperLimit;
ElevatorDown := CleaningInProgress AND AtUpperLimitLatch AND NOT LowerLimit;
RotateClockwise := CleaningInProgress AND AtUpperLimitLatch AND NOT LowerLimit;
WaterPump := CleaningInProgress AND AtUpperLimitLatch AND NOT LowerLimit;

(* Final safety override - ensure no conflicting outputs *)
IF ElevatorUp AND ElevatorDown THEN
    ElevatorUp := FALSE;
    ElevatorDown := FALSE;
END_IF;

END_FUNCTION_BLOCK;