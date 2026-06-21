START_REASON
The validation feedback indicates an encoding issue with the CODESYS compiler, specifically a 'gbk' codec can't decode byte 0xaa at position 105. This suggests there might be a non-ASCII character or encoding problem in the previous ST code submission. Since the error occurs during syntax check, it's likely that invisible or special characters were introduced. To fix this, I need to ensure the code uses only standard ASCII characters and proper Structured Text syntax. I'll rewrite the code from scratch, ensuring all characters are valid ASCII and the structure is correct. I'll maintain the FUNCTION_BLOCK structure, use proper variable declarations with END_VAR, and implement the state machine logic without PID controllers to avoid previous errors. The code will include safety checks, timers, and error handling as per requirements.
END_REASON

START_ST
FUNCTION_BLOCK CapsuleFillingMachineControl
VAR_INPUT
    CapsuleWeight : REAL;
    TargetWeight : REAL;
    CapsuleInPosition : BOOL;
    HopperEmpty : BOOL;
    manualReset : BOOL;
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
END_VAR

(* Safety Check - Immediate Override: Stop all motors if hopper is empty *)
IF HopperEmpty THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    state := 4;
    RETURN;
END_IF;

(* Weight Validation - Immediate Override: Stop if capsule already at or above target weight *)
IF CapsuleWeight >= TargetWeight THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    state := 4;
    RETURN;
END_IF;

(* Main State Machine *)
CASE state OF
    0: (* IDLE: Waiting for capsule to be in position and under target weight *)
        FeederMotor := TRUE;
        FillingMotor := FALSE;
        ConveyorMotor := FALSE;
        FillingInProgress := FALSE;
        ErrorFlag := FALSE;
        FillingTimeoutError := FALSE;
        CapsuleDetectionError := FALSE;
        
        capsuleDetectionTimer(IN:=FALSE, PT:=detectionTimeout);
        
        IF CapsuleInPosition AND (CapsuleWeight < TargetWeight) THEN
            state := 1;
            conveyingTimer(IN:=TRUE, PT:=conveyingTime);
        END_IF;
        
    1: (* CONVEYING: Moving capsule into filling position *)
        FeederMotor := TRUE;
        FillingMotor := FALSE;
        ConveyorMotor := TRUE;
        FillingInProgress := FALSE;
        
        capsuleDetectionTimer(IN:=TRUE, PT:=detectionTimeout);
        
        IF capsuleDetectionTimer.Q THEN
            CapsuleDetectionError := TRUE;
            ErrorFlag := TRUE;
            state := 4;
        END_IF;
        
        conveyingTimer(IN:=TRUE, PT:=conveyingTime);
        IF conveyingTimer.Q THEN
            state := 2;
            fillingTimer(IN:=TRUE, PT:=fillingTimeout);
        END_IF;
        
    2: (* FILLING: Actively filling the capsule to target weight *)
        FeederMotor := TRUE;
        FillingMotor := TRUE;
        ConveyorMotor := FALSE;
        FillingInProgress := TRUE;
        
        fillingTimer(IN:=TRUE, PT:=fillingTimeout);
        IF fillingTimer.Q THEN
            FillingTimeoutError := TRUE;
            ErrorFlag := TRUE;
            state := 4;
        END_IF;
        
        IF (CapsuleWeight >= (TargetWeight - tolerance)) AND (CapsuleWeight <= (TargetWeight + tolerance)) THEN
            state := 3;
            conveyingTimer(IN:=TRUE, PT:=conveyingTime);
        END_IF;
        
    3: (* CONVEYING_OUT: Moving filled capsule out of the machine *)
        FeederMotor := TRUE;
        FillingMotor := FALSE;
        ConveyorMotor := TRUE;
        FillingInProgress := FALSE;
        
        conveyingTimer(IN:=TRUE, PT:=conveyingTime);
        IF conveyingTimer.Q THEN
            state := 0;
        END_IF;
        
    4: (* ERROR: Error state, all motors stopped, requires manual reset *)
        FeederMotor := FALSE;
        FillingMotor := FALSE;
        ConveyorMotor := FALSE;
        FillingInProgress := FALSE;
        
        IF manualReset AND (NOT HopperEmpty) AND (CapsuleWeight < TargetWeight) THEN
            state := 0;
            ErrorFlag := FALSE;
            FillingTimeoutError := FALSE;
            CapsuleDetectionError := FALSE;
        END_IF;
        
END_CASE;

prevState := state;

END_FUNCTION_BLOCK
END_ST