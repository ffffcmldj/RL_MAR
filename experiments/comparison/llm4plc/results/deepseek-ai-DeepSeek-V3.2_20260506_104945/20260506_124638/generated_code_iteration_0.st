START_ST
FUNCTION_BLOCK CapsuleFillingMachineControl
VAR_INPUT
    CapsuleWeight : REAL;
    TargetWeight : REAL;
    CapsuleInPosition : BOOL;
    HopperEmpty : BOOL;
END_VAR
VAR_OUTPUT
    FeederMotor : BOOL;
    FillingMotor : BOOL;
    ConveyorMotor : BOOL;
    FillingInProgress : BOOL;
    ErrorFlag : BOOL;
    FillingTimeoutError : BOOL;
    CapsuleDetectionError : BOOL;
END_VAR
VAR
    state : INT;
    prevState : INT;
    fillingTimer : TON;
    conveyingTimer : TON;
    capsuleDetectionTimer : TON;
    tolerance : REAL := 0.1;
    conveyingTime : TIME := T#2s;
    fillingTimeout : TIME := T#10s;
    detectionTimeout : TIME := T#5s;
    pidController : PID;
    pidSetpoint : REAL;
    pidInput : REAL;
    pidOutput : REAL;
    pidKp : REAL := 1.0;
    pidKi : REAL := 0.1;
    pidKd : REAL := 0.05;
    manualReset : BOOL;
END_VAR

(* Safety Check - Immediate Override *)
IF HopperEmpty THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    state := 4; (* ERROR state *)
    RETURN;
END_IF;

(* Weight Validation - Immediate Override *)
IF CapsuleWeight >= TargetWeight THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    state := 4; (* ERROR state *)
    RETURN;
END_IF;

(* Main State Machine *)
CASE state OF
    0: (* IDLE *)
        FeederMotor := TRUE; (* Assumption: Feeder ON when not empty *)
        FillingMotor := FALSE;
        ConveyorMotor := FALSE;
        FillingInProgress := FALSE;
        ErrorFlag := FALSE;
        FillingTimeoutError := FALSE;
        CapsuleDetectionError := FALSE;
        
        capsuleDetectionTimer(IN:=FALSE, PT:=detectionTimeout);
        
        IF CapsuleInPosition AND (CapsuleWeight < TargetWeight) THEN
            state := 1; (* CONVEYING *)
            conveyingTimer(IN:=TRUE, PT:=conveyingTime);
        END_IF;
        
    1: (* CONVEYING *)
        FeederMotor := TRUE;
        FillingMotor := FALSE;
        ConveyorMotor := TRUE;
        FillingInProgress := FALSE;
        
        capsuleDetectionTimer(IN:=TRUE, PT:=detectionTimeout);
        
        (* Capsule Not Detected Error *)
        IF capsuleDetectionTimer.Q THEN
            CapsuleDetectionError := TRUE;
            ErrorFlag := TRUE;
            state := 4; (* ERROR *)
        END_IF;
        
        (* Transition to FILLING after conveying time *)
        conveyingTimer(IN:=TRUE, PT:=conveyingTime);
        IF conveyingTimer.Q THEN
            state := 2; (* FILLING *)
            fillingTimer(IN:=TRUE, PT:=fillingTimeout);
            pidSetpoint := TargetWeight;
        END_IF;
        
    2: (* FILLING *)
        FeederMotor := TRUE;
        FillingMotor := TRUE;
        ConveyorMotor := FALSE;
        FillingInProgress := TRUE;
        
        (* PID Control for Filling *)
        pidInput := CapsuleWeight;
        pidController(
            Setpoint:=pidSetpoint,
            Input:=pidInput,
            Kp:=pidKp,
            Ki:=pidKi,
            Kd:=pidKd,
            Output=>pidOutput
        );
        (* Note: In practice, pidOutput would control FillingMotor speed/valve *)
        
        (* Filling Timeout Error *)
        fillingTimer(IN:=TRUE, PT:=fillingTimeout);
        IF fillingTimer.Q THEN
            FillingTimeoutError := TRUE;
            ErrorFlag := TRUE;
            state := 4; (* ERROR *)
        END_IF;
        
        (* Weight Check with Tolerance *)
        IF CapsuleWeight >= (TargetWeight - tolerance) AND CapsuleWeight <= (TargetWeight + tolerance) THEN
            state := 3; (* CONVEYING_OUT *)
            conveyingTimer(IN:=TRUE, PT:=conveyingTime);
        END_IF;
        
    3: (* CONVEYING_OUT *)
        FeederMotor := TRUE;
        FillingMotor := FALSE;
        ConveyorMotor := TRUE;
        FillingInProgress := FALSE;
        
        (* Transition back to IDLE after conveying out *)
        conveyingTimer(IN:=TRUE, PT:=conveyingTime);
        IF conveyingTimer.Q THEN
            state := 0; (* IDLE *)
        END_IF;
        
    4: (* ERROR *)
        FeederMotor := FALSE;
        FillingMotor := FALSE;
        ConveyorMotor := FALSE;
        FillingInProgress := FALSE;
        
        (* Manual Reset Required *)
        IF manualReset AND NOT HopperEmpty AND (CapsuleWeight < TargetWeight) THEN
            state := 0; (* IDLE *)
            ErrorFlag := FALSE;
            FillingTimeoutError := FALSE;
            CapsuleDetectionError := FALSE;
        END_IF;
        
END_CASE;

(* Store previous state for debugging/monitoring *)
prevState := state;

END_FUNCTION_BLOCK
END_ST