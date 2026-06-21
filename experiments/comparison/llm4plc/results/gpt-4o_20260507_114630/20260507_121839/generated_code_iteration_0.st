plaintext
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
    state : INT := 0; (* Current state of the system *)
    prevState : INT := 0; (* Previous state of the system, optional for debugging *)
    SpeedLimit : REAL := 60.0; (* Maximum allowed speed in RPM *)
END_VAR

(* State Definitions *)
CONST
    STATE_INITIALIZE : INT := 0; (* Initialize state *)
    STATE_EMERGENCY_STOP : INT := 1; (* Emergency stop state *)
    STATE_CHECK_START_CONDITIONS : INT := 2; (* Check start conditions state *)
    STATE_NORMAL_OPERATION : INT := 3; (* Normal operation state *)
END_CONST

(* Main Logic *)
CASE state OF
    (* STATE 0: INITIALIZE *)
    STATE_INITIALIZE:
        MotorOn := FALSE;
        BrakeOn := TRUE;
        IF StopButton THEN
            state := STATE_EMERGENCY_STOP; (* Transition to Emergency Stop *)
        ELSE
            state := STATE_CHECK_START_CONDITIONS; (* Transition to Check Start Conditions *)
        END_IF;

    (* STATE 1: EMERGENCY STOP *)
    STATE_EMERGENCY_STOP:
        MotorOn := FALSE;
        BrakeOn := TRUE;
        IF NOT StopButton THEN
            state := STATE_CHECK_START_CONDITIONS; (* Transition to Check Start Conditions *)
        END_IF;

    (* STATE 2: CHECK START CONDITIONS *)
    STATE_CHECK_START_CONDITIONS:
        IF StopButton THEN
            state := STATE_EMERGENCY_STOP; (* Transition to Emergency Stop *)
        ELSIF StartButton AND NOT StopButton AND (SpeedSensor <= SpeedLimit) AND SafetySensor THEN
            MotorOn := TRUE;
            BrakeOn := FALSE;
            state := STATE_NORMAL_OPERATION; (* Transition to Normal Operation *)
        ELSE
            MotorOn := FALSE;
            BrakeOn := TRUE; (* Remain in Check Start Conditions *)
        END_IF;

    (* STATE 3: NORMAL OPERATION *)
    STATE_NORMAL_OPERATION:
        MotorOn := TRUE;
        BrakeOn := FALSE;
        IF StopButton THEN
            state := STATE_EMERGENCY_STOP; (* Transition to Emergency Stop *)
        ELSIF (SpeedSensor > SpeedLimit) OR NOT SafetySensor THEN
            MotorOn := FALSE;
            BrakeOn := TRUE;
            state := STATE_CHECK_START_CONDITIONS; (* Transition to Check Start Conditions *)
        END_IF;

    (* Default Case: Fail-Safe *)
    ELSE
        MotorOn := FALSE;
        BrakeOn := TRUE;
        state := STATE_INITIALIZE; (* Transition to Initialize *)
END_CASE;

END_FUNCTION_BLOCK
END_ST