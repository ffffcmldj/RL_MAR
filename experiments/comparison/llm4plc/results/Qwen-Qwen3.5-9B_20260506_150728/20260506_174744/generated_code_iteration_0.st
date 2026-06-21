START_ST
FUNCTION_BLOCK AmusementRideControl
VAR_INPUT
    StartButton : BOOL; (* Start button input *)
    StopButton : BOOL; (* Emergency stop button input *)
    SpeedSensor : REAL; (* Speed sensor input (RPM) *)
    SafetySensor : BOOL; (* Safety sensor status *)
END_VAR
VAR_OUTPUT
    MotorOn : BOOL := FALSE; (* Motor control output *)
    BrakeOn : BOOL := TRUE; (* Brake control output *)
END_VAR
VAR
    state : INT := 0; (* Current FSM State: 0=Idle, 1=StartSeq, 2=Running, 3=Emergency *)
    nextState : INT; (* Calculated state for the next scan cycle *)
    speedLimit : REAL := 60.0; (* Maximum allowed speed in RPM *)
END_VAR

(* ============================================================================
   STATE MACHINE LOGIC
   ============================================================================ *)

(* 1. Determine the Next State based on current state and inputs *)
CASE state OF
    0: (* STATE 0: IDLE (DEFAULT/FAIL-SAFE) *)
        (* Transition to Start_Sequence if StartButton is pressed and StopButton is released *)
        IF StartButton AND NOT StopButton THEN
            nextState := 1; (* Transition to STATE 1: START_SEQUENCE *)
        ELSE
            nextState := 0; (* Remain in STATE 0 *)
        END_IF;

    1: (* STATE 1: START_SEQUENCE *)
        (* Transition to Running only if ALL start conditions are met simultaneously *)
        IF StartButton AND NOT StopButton AND (SpeedSensor <= speedLimit) AND SafetySensor THEN
            nextState := 2; (* Transition to STATE 2: RUNNING *)
        ELSE
            nextState := 0; (* If conditions fail, return to STATE 0: IDLE *)
        END_IF;

    2: (* STATE 2: RUNNING *)
        (* Transition to Emergency_Stop if StopButton pressed OR speed limit exceeded OR safety sensor fails *)
        IF StopButton OR (SpeedSensor > speedLimit) OR (NOT SafetySensor) THEN
            nextState := 3; (* Transition to STATE 3: EMERGENCY_STOP *)
        ELSE
            nextState := 2; (* Remain in STATE 2: RUNNING *)
        END_IF;

    3: (* STATE 3: EMERGENCY_STOP *)
        (* Transition back to Idle only when StopButton is released *)
        IF NOT StopButton THEN
            nextState := 0; (* Transition to STATE 0: IDLE *)
        ELSE
            nextState := 3; (* Remain in STATE 3: EMERGENCY_STOP *)
        END_IF;
END_CASE

(* 2. Update Current State *)
state := nextState;

(* ============================================================================
   OUTPUT ASSIGNMENT BASED ON CURRENT STATE
   ============================================================================ *)

CASE state OF
    0: (* STATE 0: IDLE *)
        MotorOn := FALSE;
        BrakeOn := TRUE;

    1: (* STATE 1: START_SEQUENCE *)
        MotorOn := FALSE;
        BrakeOn := TRUE;

    2: (* STATE 2: RUNNING *)
        MotorOn := TRUE;
        BrakeOn := FALSE;

    3: (* STATE 3: EMERGENCY_STOP *)
        MotorOn := FALSE;
        BrakeOn := TRUE;
END_CASE

END_FUNCTION_BLOCK
END_ST