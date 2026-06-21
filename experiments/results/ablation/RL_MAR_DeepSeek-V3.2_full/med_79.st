FUNCTION_BLOCK CapsuleFillingMachineControl
VAR_INPUT
    CapsuleWeight : REAL;        (* Current capsule weight *)
    TargetWeight : REAL;         (* Target weight to achieve *)
    CapsuleInPosition : BOOL;    (* Capsule position sensor *)
    HopperEmpty : BOOL;          (* Hopper empty sensor *)
END_VAR
VAR_OUTPUT
    FeederMotor : BOOL;          (* Feeder motor control *)
    FillingMotor : BOOL;         (* Filling motor control *)
    ConveyorMotor : BOOL;        (* Conveyor motor control *)
    FillingInProgress : BOOL;    (* Filling status *)
    ErrorCode : INT;             (* Error indication: 0=OK, 1=CapsuleNotDetected, 2=FillingTimeout *)
END_VAR
VAR
    (* State machine *)
    CurrentState : INT := 0;     (* 0=IDLE, 1=CONVEYING, 2=FILLING, 3=CONVEYING_OUT *)
    
    (* Timers *)
    ConveyorTimer : TON;
    FillingTimer : TON;
    ConveyOutTimer : TON;
    
    (* Timing parameters *)
    ConveyorTime : TIME := T#2S;
    MaxFillingTime : TIME := T#10S;
    ConveyOutTime : TIME := T#1S;
    
    (* Error detection *)
    CapsuleDetectTimeout : TON;
    CapsuleDetectTime : TIME := T#5S;
    
    (* Filling control *)
    WeightTolerance : REAL := 0.1;
    FillingSpeed : REAL := 0.0;
    LastCapsuleWeight : REAL := 0.0;
    
    (* Internal flags *)
    CapsuleDetected : BOOL := FALSE;
    FillingComplete : BOOL := FALSE;
    ErrorFlag : BOOL := FALSE;
END_VAR

(* Safety Check: Hopper Empty *)
IF HopperEmpty THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    ErrorCode := 0;
    CurrentState := 0;
    RETURN;
END_IF;

(* Weight Validation: Initial Check *)
IF CapsuleWeight >= TargetWeight AND NOT FillingInProgress THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    ErrorCode := 0;
    CurrentState := 0;
    RETURN;
END_IF;

(* State Machine Execution *)
CASE CurrentState OF
    0: (* IDLE *)
        FeederMotor := TRUE;
        FillingMotor := FALSE;
        ConveyorMotor := FALSE;
        FillingInProgress := FALSE;
        FillingComplete := FALSE;
        ErrorFlag := FALSE;
        ErrorCode := 0;
        
        (* Reset timers *)
        ConveyorTimer(IN:=FALSE, PT:=ConveyorTime);
        FillingTimer(IN:=FALSE, PT:=MaxFillingTime);
        ConveyOutTimer(IN:=FALSE, PT:=ConveyOutTime);
        CapsuleDetectTimeout(IN:=FALSE, PT:=CapsuleDetectTime);
        
        (* Check for capsule detection *)
        IF CapsuleInPosition THEN
            CapsuleDetected := TRUE;
            CurrentState := 1; (* Move to CONVEYING state *)
            ConveyorTimer(IN:=TRUE, PT:=ConveyorTime);
        ELSE
            (* Start capsule detection timeout *)
            CapsuleDetectTimeout(IN:=TRUE, PT:=CapsuleDetectTime);
            IF CapsuleDetectTimeout.Q THEN
                ErrorCode := 1; (* CapsuleNotDetected *)
                ErrorFlag := TRUE;
            END_IF;
        END_IF;
        
    1: (* CONVEYING *)
        FeederMotor := TRUE;
        FillingMotor := FALSE;
        ConveyorMotor := TRUE;
        FillingInProgress := FALSE;
        
        (* Run conveyor timer *)
        ConveyorTimer(IN:=TRUE, PT:=ConveyorTime);
        
        IF ConveyorTimer.Q THEN
            (* Conveying complete, start filling *)
            CurrentState := 2; (* Move to FILLING state *)
            FillingTimer(IN:=TRUE, PT:=MaxFillingTime);
            FillingInProgress := TRUE;
            LastCapsuleWeight := CapsuleWeight;
        END_IF;
        
    2: (* FILLING *)
        FeederMotor := TRUE;
        ConveyorMotor := FALSE;
        FillingInProgress := TRUE;
        
        (* Simple proportional filling control *)
        IF TargetWeight > CapsuleWeight THEN
            (* Calculate filling speed based on weight difference *)
            FillingSpeed := (TargetWeight - CapsuleWeight) / TargetWeight;
            
            (* Limit filling speed between 0.1 and 1.0 *)
            IF FillingSpeed < 0.1 THEN
                FillingSpeed := 0.1;
            ELSIF FillingSpeed > 1.0 THEN
                FillingSpeed := 1.0;
            END_IF;
            
            (* Control filling motor with speed-based duty cycle *)
            FillingMotor := TRUE;
        ELSE
            FillingMotor := FALSE;
            FillingComplete := TRUE;
        END_IF;
        
        (* Check if target weight is reached within tolerance *)
        IF CapsuleWeight >= (TargetWeight - WeightTolerance) THEN
            FillingMotor := FALSE;
            FillingComplete := TRUE;
        END_IF;
        
        (* Check for filling timeout *)
        FillingTimer(IN:=TRUE, PT:=MaxFillingTime);
        IF FillingTimer.Q AND NOT FillingComplete THEN
            ErrorCode := 2; (* FillingTimeout *)
            ErrorFlag := TRUE;
            CurrentState := 0; (* Return to IDLE *)
        END_IF;
        
        (* Move to next state when filling is complete *)
        IF FillingComplete AND NOT ErrorFlag THEN
            CurrentState := 3; (* Move to CONVEYING_OUT state *)
            ConveyOutTimer(IN:=TRUE, PT:=ConveyOutTime);
        END_IF;
        
    3: (* CONVEYING_OUT *)
        FeederMotor := TRUE;
        FillingMotor := FALSE;
        ConveyorMotor := TRUE;
        FillingInProgress := FALSE;
        
        (* Run conveyor out timer *)
        ConveyOutTimer(IN:=TRUE, PT:=ConveyOutTime);
        
        IF ConveyOutTimer.Q THEN
            (* Conveying out complete, return to IDLE *)
            CurrentState := 0;
            CapsuleDetected := FALSE;
            FillingComplete := FALSE;
        END_IF;
        
END_CASE;

(* Update timers *)
ConveyorTimer();
FillingTimer();
ConveyOutTimer();
CapsuleDetectTimeout();

END_FUNCTION_BLOCK