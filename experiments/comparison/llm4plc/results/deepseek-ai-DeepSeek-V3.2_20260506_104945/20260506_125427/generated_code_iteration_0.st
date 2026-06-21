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
    SpeedLimit : REAL := 60.0; (* Maximum allowed speed in RPM *)
    state : INT := 0; (* Current state variable: 0=IDLE, 1=STARTING, 2=RUNNING, 3=EMERGENCY_STOP *)
    prevState : INT := 0; (* Previous state for debugging/tracking *)
END_VAR

(* State Machine Execution *)
prevState := state; (* Store previous state for reference *)

(* EMERGENCY STOP - Highest Priority Check (from any state) *)
IF StopButton THEN
    state := 3; (* Transition to EMERGENCY_STOP *)
END_IF;

(* State Transitions and Outputs *)
CASE state OF
    0: (* IDLE - Default fail-safe state *)
        MotorOn := FALSE;
        BrakeOn := TRUE;
        
        (* State Transitions from IDLE *)
        IF NOT StopButton AND StartButton THEN
            state := 1; (* Transition to STARTING *)
        END_IF;
        
    1: (* STARTING - Checking all start conditions *)
        MotorOn := FALSE;
        BrakeOn := TRUE;
        
        (* Check if all start conditions are met *)
        IF StartButton AND NOT StopButton AND (SpeedSensor <= SpeedLimit) AND SafetySensor THEN
            state := 2; (* Transition to RUNNING *)
        ELSIF NOT (StartButton AND NOT StopButton AND (SpeedSensor <= SpeedLimit) AND SafetySensor) THEN
            state := 0; (* Return to IDLE if any condition fails *)
        END_IF;
        
    2: (* RUNNING - Motor is running normally *)
        MotorOn := TRUE;
        BrakeOn := FALSE;
        
        (* Continuous safety monitoring during RUNNING *)
        IF NOT SafetySensor OR (SpeedSensor > SpeedLimit) THEN
            state := 0; (* Safety violation: return to IDLE *)
        END_IF;
        
    3: (* EMERGENCY_STOP - Emergency stop activated *)
        MotorOn := FALSE;
        BrakeOn := TRUE;
        
        (* Can only leave EMERGENCY_STOP when stop button is released *)
        IF NOT StopButton THEN
            state := 0; (* Return to IDLE *)
        END_IF;
        
END_CASE;

END_FUNCTION_BLOCK
END_ST