(*
    FUNCTION_BLOCK AmusementRideControl
    Safety control system for an amusement ride with strict fail-safe principles.
    
    Safety Properties Verified:
    1. Emergency Stop has highest priority and immediately stops motor
    2. Motor and Brake are never active simultaneously
    3. Motor only runs when ALL start conditions are met
    4. System defaults to safe state (brake engaged, motor off)
    
    Inputs:
        StartButton  : BOOL  - Start command (must be TRUE to run)
        StopButton   : BOOL  - Emergency stop (TRUE = emergency active)
        SpeedSensor  : REAL  - Current speed measurement (RPM)
        SafetySensor : BOOL  - Safety interlock status (TRUE = safe)
    
    Outputs:
        MotorOn : BOOL - Motor control (TRUE = run, FALSE = stop)
        BrakeOn : BOOL - Brake control (TRUE = engaged, FALSE = released)
    
    Internal:
        SpeedLimit : REAL - Maximum allowed speed (RPM)
*)

FUNCTION_BLOCK AmusementRideControl
VAR_INPUT
    StartButton  : BOOL;  (* Start button input *)
    StopButton   : BOOL;  (* Emergency stop button input *)
    SpeedSensor  : REAL;  (* Speed sensor input (RPM) *)
    SafetySensor : BOOL;  (* Safety sensor status *)
END_VAR

VAR_OUTPUT
    MotorOn : BOOL := FALSE;  (* Motor control output *)
    BrakeOn : BOOL := TRUE;   (* Brake control output - Default to safe state *)
END_VAR

VAR
    SpeedLimit : REAL := 60.0;  (* Maximum allowed speed in RPM *)
END_VAR

(* Main Safety Logic *)
METHOD SafetyLogic : BOOL
VAR_INPUT
    bStartReq    : BOOL;
    bEmergency   : BOOL;
    rCurrentSpeed : REAL;
    rSpeedLimit   : REAL;
    bSafetyOK    : BOOL;
END_VAR
VAR_OUTPUT
    bMotorPermit : BOOL;
END_VAR
    (* Emergency Stop has ABSOLUTE highest priority *)
    IF bEmergency THEN
        bMotorPermit := FALSE;
        RETURN;
    END_IF;
    
    (* All start conditions must be met simultaneously *)
    bMotorPermit := bStartReq 
                    AND (rCurrentSpeed <= rSpeedLimit) 
                    AND bSafetyOK;
END_METHOD

(* Main execution body *)
METHOD Execute
    LOCAL_VAR
        bSafeToRun : BOOL;
    END_VAR
    
    (* Determine if it's safe to run the motor *)
    SafetyLogic(
        bStartReq := StartButton,
        bEmergency := StopButton,
        rCurrentSpeed := SpeedSensor,
        rSpeedLimit := SpeedLimit,
        bSafetyOK := SafetySensor,
        bMotorPermit => bSafeToRun
    );
    
    (* Apply safety logic with emergency stop override *)
    IF StopButton THEN
        (* CRITICAL: Emergency Stop - Highest Priority *)
        MotorOn := FALSE;
        BrakeOn := TRUE;
    ELSE
        (* Normal operation based on safety logic *)
        MotorOn := bSafeToRun;
        BrakeOn := NOT bSafeToRun;  (* Brake is opposite of motor state *)
    END_IF;
    
    (* Final safety assertion: Ensure brake is engaged if motor is off *)
    IF NOT MotorOn THEN
        BrakeOn := TRUE;
    END_IF;
END_METHOD

(* Initialization method *)
METHOD Init
    (* Initialize outputs to safe state *)
    MotorOn := FALSE;
    BrakeOn := TRUE;
    
    (* Initialize speed limit *)
    SpeedLimit := 60.0;
END_METHOD

END_FUNCTION_BLOCK;