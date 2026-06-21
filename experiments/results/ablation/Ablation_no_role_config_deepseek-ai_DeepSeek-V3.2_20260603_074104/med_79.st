FUNCTION_BLOCK CapsuleFillingMachineControl
VAR_INPUT
    CapsuleWeight : REAL;           (* Current capsule weight *)
    TargetWeight : REAL;            (* Target weight to achieve *)
    CapsuleInPosition : BOOL;       (* Capsule position sensor *)
    HopperEmpty : BOOL;             (* Hopper empty sensor *)
    HopperLowSensor : BOOL;         (* Hopper low level sensor *)
END_VAR
VAR_OUTPUT
    FeederMotor : BOOL;             (* Feeder motor control *)
    FillingMotor : BOOL;            (* Filling motor control *)
    ConveyorMotor : BOOL;           (* Conveyor motor control *)
    FillingInProgress : BOOL;       (* Filling status *)
    ErrorFlag : BOOL;               (* General error flag *)
    ErrorCode : INT;                (* Error code: 0=OK, 1=Capsule not detected, 2=Filling timeout *)
    HopperLowWarning : BOOL;        (* Hopper low level warning *)
END_VAR
VAR
    (* State machine *)
    State : INT := 0;               (* 0=IDLE, 1=CONVEYING, 2=FILLING, 3=CONVEYING_OUT, 4=ERROR *)
    
    (* Timers *)
    ConveyingTimer : TON;           (* Timer for conveying capsule to position *)
    FillingTimer : TON;             (* Timer for filling operation *)
    ConveyOutTimer : TON;           (* Timer for conveying filled capsule out *)
    CapsuleDetectTimer : TON;       (* Timer for capsule detection timeout *)
    FillingTimeoutTimer : TON;      (* Timer for filling timeout *)
    
    (* Control parameters *)
    Tolerance : REAL := 0.02;       (* Weight tolerance as percentage of target *)
    ConveyingTime : TIME := T#2S;   (* Time to convey capsule to position *)
    ConveyOutTime : TIME := T#1S;   (* Time to convey capsule out *)
    CapsuleDetectTimeout : TIME := T#5S; (* Timeout for capsule detection *)
    FillingTimeout : TIME := T#10S; (* Timeout for filling operation *)
    
    (* Internal flags *)
    CapsuleDetected : BOOL;         (* Capsule detected flag *)
    FillingComplete : BOOL;         (* Filling completion flag *)
    WeightTolerance : REAL;         (* Calculated weight tolerance *)
    
    (* Edge detection *)
    PrevCapsuleInPosition : BOOL;   (* Previous state of capsule sensor *)
    
    (* Filling control *)
    FastFillThreshold : REAL := 0.7; (* Threshold for fast/slow filling (70% of target) *)
    FillingSpeed : REAL;            (* Calculated filling speed *)
    MaxFillingSpeed : REAL := 100.0; (* Maximum filling speed *)
    MinFillingSpeed : REAL := 20.0; (* Minimum filling speed for trickle feed *)
END_VAR

(* Calculate weight tolerance *)
WeightTolerance := TargetWeight * Tolerance;

(* Hopper low level warning *)
HopperLowWarning := HopperLowSensor;

(* Safety Check: Hopper Empty *)
IF HopperEmpty THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    State := 0;  (* Return to IDLE state *)
    RETURN;
END_IF;

(* Weight Validation: Initial Check *)
IF CapsuleWeight >= (TargetWeight - WeightTolerance) THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    State := 0;  (* Return to IDLE state *)
    RETURN;
END_IF;

(* Main state machine *)
CASE State OF
    (* State 0: IDLE *)
    0:
        (* Reset all outputs *)
        FillingMotor := FALSE;
        ConveyorMotor := FALSE;
        FillingInProgress := FALSE;
        ErrorFlag := FALSE;
        ErrorCode := 0;
        
        (* Control feeder motor based on hopper level *)
        FeederMotor := NOT HopperLowSensor;
        
        (* Reset internal flags *)
        CapsuleDetected := FALSE;
        FillingComplete := FALSE;
        
        (* Reset timers *)
        ConveyingTimer(IN := FALSE, PT := ConveyingTime);
        FillingTimer(IN := FALSE, PT := FillingTimeout);
        ConveyOutTimer(IN := FALSE, PT := ConveyOutTime);
        CapsuleDetectTimer(IN := FALSE, PT := CapsuleDetectTimeout);
        FillingTimeoutTimer(IN := FALSE, PT := FillingTimeout);
        
        (* Transition to CONVEYING when capsule is detected *)
        IF CapsuleInPosition AND NOT PrevCapsuleInPosition THEN
            CapsuleDetected := TRUE;
            State := 1;  (* Move to CONVEYING state *)
        END_IF;
    
    (* State 1: CONVEYING *)
    1:
        FillingInProgress := FALSE;
        ConveyorMotor := TRUE;
        FeederMotor := NOT HopperLowSensor;
        
        (* Start conveying timer *)
        ConveyingTimer(IN := TRUE, PT := ConveyingTime);
        
        (* Start capsule detection timeout timer *)
        CapsuleDetectTimer(IN := TRUE, PT := CapsuleDetectTimeout);
        
        (* Check for capsule detection timeout *)
        IF CapsuleDetectTimer.Q THEN
            ErrorFlag := TRUE;
            ErrorCode := 1;  (* Capsule not detected error *)
            State := 4;      (* Move to ERROR state *)
        END_IF;
        
        (* Transition to FILLING when conveying time elapsed *)
        IF ConveyingTimer.Q THEN
            ConveyorMotor := FALSE;
            State := 2;  (* Move to FILLING state *)
        END_IF;
    
    (* State 2: FILLING *)
    2:
        FillingInProgress := TRUE;
        ConveyorMotor := FALSE;
        FeederMotor := NOT HopperLowSensor;
        
        (* Start filling timeout timer *)
        FillingTimeoutTimer(IN := TRUE, PT := FillingTimeout);
        
        (* Advanced filling control with fast/slow phases *)
        IF CapsuleWeight < (TargetWeight * FastFillThreshold) THEN
            (* Fast filling phase *)
            FillingSpeed := MaxFillingSpeed;
            FillingMotor := TRUE;
        ELSE
            (* Slow trickle feed phase *)
            FillingSpeed := MinFillingSpeed;
            
            (* Calculate remaining weight difference *)
            IF (TargetWeight - CapsuleWeight) > WeightTolerance THEN
                FillingMotor := TRUE;
            ELSE
                FillingMotor := FALSE;
                FillingComplete := TRUE;
            END_IF;
        END_IF;
        
        (* Check for filling completion *)
        IF CapsuleWeight >= (TargetWeight - WeightTolerance) THEN
            FillingMotor := FALSE;
            FillingComplete := TRUE;
            State := 3;  (* Move to CONVEYING_OUT state *)
        END_IF;
        
        (* Check for filling timeout *)
        IF FillingTimeoutTimer.Q THEN
            ErrorFlag := TRUE;
            ErrorCode := 2;  (* Filling timeout error *)
            State := 4;      (* Move to ERROR state *)
        END_IF;
    
    (* State 3: CONVEYING_OUT *)
    3:
        FillingInProgress := FALSE;
        FillingMotor := FALSE;
        ConveyorMotor := TRUE;
        FeederMotor := NOT HopperLowSensor;
        
        (* Start convey out timer *)
        ConveyOutTimer(IN := TRUE, PT := ConveyOutTime);
        
        (* Transition back to IDLE when convey out time elapsed *)
        IF ConveyOutTimer.Q THEN
            ConveyorMotor := FALSE;
            State := 0;  (* Return to IDLE state *)
        END_IF;
    
    (* State 4: ERROR *)
    4:
        (* Safety stop all motors *)
        FeederMotor := FALSE;
        FillingMotor := FALSE;
        ConveyorMotor := FALSE;
        FillingInProgress := FALSE;
        
        (* Error state persists until manually reset *)
        (* To reset: Set State := 0 from external program *)
    
END_CASE;

(* Update edge detection variable *)
PrevCapsuleInPosition := CapsuleInPosition;

END_FUNCTION_BLOCK