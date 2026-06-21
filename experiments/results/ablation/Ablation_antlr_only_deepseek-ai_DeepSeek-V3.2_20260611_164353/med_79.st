(*
    CAPSULE FILLING MACHINE CONTROL FUNCTION BLOCK
    IEC 61131-3 Structured Text
    Implements a state machine with PID control for precise pharmaceutical filling
*)

TYPE E_ErrorCodes :
(
    ERR_NONE := 0,
    ERR_HOPPER_EMPTY := 1,
    ERR_OVERWEIGHT_INITIAL := 2,
    ERR_CAPSULE_DETECT_TIMEOUT := 3,
    ERR_FILLING_TIMEOUT := 4,
    ERR_EMERGENCY_STOP := 5,
    ERR_TARGET_ZERO := 6
);
END_TYPE

TYPE E_States :
(
    STATE_IDLE := 0,
    STATE_CONVEYING_IN := 1,
    STATE_FILLING := 2,
    STATE_CONVEYING_OUT := 3,
    STATE_ERROR := 99
);
END_TYPE

FUNCTION_BLOCK CapsuleFillingMachineControl
VAR_INPUT
    (* Core Process Inputs *)
    CapsuleWeight : REAL;           (* Current capsule weight measurement *)
    TargetWeight : REAL;            (* Target weight to achieve *)
    CapsuleInPosition : BOOL;       (* Capsule position sensor at entry *)
    HopperEmpty : BOOL;             (* Hopper empty sensor *)
    
    (* Extended Process Inputs *)
    HopperLowLevel : BOOL;          (* Hopper low level warning sensor *)
    EmergencyStop : BOOL;           (* Emergency stop button *)
    
    (* Timing Parameters *)
    ConveyorTime : TIME := T#2S;    (* Time to convey capsule to filling station *)
    FillingTimeout : TIME := T#10S; (* Maximum allowed filling time *)
    DetectionTimeout : TIME := T#5S;(* Timeout for capsule detection *)
    ConveyOutTime : TIME := T#2S;   (* Time to convey filled capsule out *)
    
    (* Control Parameters *)
    Tolerance : REAL := 0.01;       (* Weight tolerance for filling completion *)
    Kp : REAL := 1.0;               (* PID Proportional gain *)
    Ki : REAL := 0.1;               (* PID Integral gain *)
    Kd : REAL := 0.01;              (* PID Derivative gain *)
    ManualOverride : BOOL := FALSE; (* Manual override flag *)
END_VAR

VAR_OUTPUT
    (* Motor Controls *)
    FeederMotor : BOOL;             (* Controls material supply to hopper *)
    FillingMotor : BOOL;            (* Controls filling mechanism *)
    ConveyorMotor : BOOL;           (* Controls capsule conveyor *)
    
    (* Status Indicators *)
    FillingInProgress : BOOL;       (* TRUE during active filling *)
    WarningLight : BOOL;            (* Activated for hopper low level *)
    ErrorCode : E_ErrorCodes;       (* Current error state *)
    
    (* Diagnostic Outputs *)
    PIDOutput : REAL;               (* Current PID controller output *)
    WeightDeviation : REAL;         (* Deviation from target weight *)
    CurrentState : E_States;        (* Current state machine state *)
END_VAR

VAR
    (* State Machine *)
    State : E_States := STATE_IDLE;
    PreviousState : E_States;
    
    (* Timers *)
    ConveyorTimer : TON;
    FillingTimer : TON;
    DetectionTimer : TON;
    ConveyOutTimer : TON;
    
    (* PID Controller *)
    PID_Controller : PID;
    ControlOutput : REAL;
    Setpoint : REAL;
    ProcessValue : REAL;
    
    (* Flags *)
    CapsuleDetected : BOOL;
    WeightReached : BOOL;
    FillingComplete : BOOL;
    ConveyingComplete : BOOL;
    
    (* Error Handling *)
    CapsuleDetectFlag : BOOL;
    FillingTimeoutFlag : BOOL;
    OverweightError : BOOL;
    HopperLowWarning : BOOL;
    EmergencyStopActive : BOOL;
    
    (* Cycle Management *)
    CycleCounter : DINT;
    ErrorCounter : DINT;
    
    (* Weight Statistics *)
    WeightArray : ARRAY[1..100] OF REAL;
    AverageWeight : REAL;
    WeightSum : REAL := 0;
    ArrayIndex : INT := 1;
END_VAR

(* Initialize outputs *)
FeederMotor := FALSE;
FillingMotor := FALSE;
ConveyorMotor := FALSE;
FillingInProgress := FALSE;
WarningLight := FALSE;
ErrorCode := ERR_NONE;
PIDOutput := 0.0;
WeightDeviation := 0.0;
CurrentState := State;

(* Emergency Stop - Highest Priority *)
IF EmergencyStop THEN
    EmergencyStopActive := TRUE;
    ErrorCode := ERR_EMERGENCY_STOP;
    State := STATE_ERROR;
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    RETURN;
ELSE
    EmergencyStopActive := FALSE;
END_IF

(* Safety Check 1: Hopper Empty *)
IF HopperEmpty THEN
    ErrorCode := ERR_HOPPER_EMPTY;
    State := STATE_IDLE;
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    RETURN;
END_IF

(* Safety Check 2: Invalid Target Weight *)
IF TargetWeight <= 0 THEN
    ErrorCode := ERR_TARGET_ZERO;
    State := STATE_IDLE;
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    RETURN;
END_IF

(* Hopper Low Level Warning *)
IF HopperLowLevel THEN
    WarningLight := TRUE;
    HopperLowWarning := TRUE;
ELSE
    WarningLight := FALSE;
    HopperLowWarning := FALSE;
END_IF

(* Feeder Motor Control - runs when hopper is not empty and not in error *)
FeederMotor := NOT HopperEmpty AND NOT EmergencyStopActive;

(* Main State Machine *)
CASE State OF
    STATE_IDLE:
        (* Reset flags and timers *)
        FillingInProgress := FALSE;
        ConveyorTimer(IN := FALSE);
        FillingTimer(IN := FALSE);
        DetectionTimer(IN := FALSE);
        ConveyOutTimer(IN := FALSE);
        CapsuleDetected := FALSE;
        WeightReached := FALSE;
        FillingComplete := FALSE;
        ConveyingComplete := FALSE;
        
        (* Safety Check 3: Initial Overweight Detection *)
        IF CapsuleWeight >= TargetWeight THEN
            OverweightError := TRUE;
            ErrorCode := ERR_OVERWEIGHT_INITIAL;
            State := STATE_ERROR;
            RETURN;
        END_IF;
        
        (* Wait for capsule detection *)
        IF CapsuleInPosition THEN
            State := STATE_CONVEYING_IN;
            ConveyorTimer(IN := TRUE, PT := ConveyorTime);
            DetectionTimer(IN := TRUE, PT := DetectionTimeout);
        END_IF;
        
    STATE_CONVEYING_IN:
        (* Activate conveyor to move capsule to filling station *)
        ConveyorMotor := TRUE;
        ConveyorTimer(IN := TRUE);
        DetectionTimer(IN := TRUE);
        
        (* Check for successful conveyance *)
        IF ConveyorTimer.Q THEN
            ConveyingComplete := TRUE;
            ConveyorTimer(IN := FALSE);
            DetectionTimer(IN := FALSE);
            State := STATE_FILLING;
            FillingTimer(IN := TRUE, PT := FillingTimeout);
            
        (* Check for capsule detection timeout *)
        ELSIF DetectionTimer.Q THEN
            CapsuleDetectFlag := TRUE;
            ErrorCode := ERR_CAPSULE_DETECT_TIMEOUT;
            ConveyorTimer(IN := FALSE);
            DetectionTimer(IN := FALSE);
            State := STATE_ERROR;
        END_IF;
        
    STATE_FILLING:
        (* Set filling status *)
        FillingInProgress := TRUE;
        
        (* Configure PID Controller *)
        Setpoint := TargetWeight;
        ProcessValue := CapsuleWeight;
        
        (* Initialize PID parameters on first entry *)
        IF PreviousState <> STATE_FILLING THEN
            PID_Controller.Kp := Kp;
            PID_Controller.Ki := Ki;
            PID_Controller.Kd := Kd;
            PID_Controller.Ts := T#20MS;  (* Sample time *)
        END_IF;
        
        (* Execute PID control *)
        PID_Controller(
            Setpoint := Setpoint,
            ProcessValue := ProcessValue,
            ControlOutput => ControlOutput
        );
        
        (* Convert PID output to motor control *)
        PIDOutput := ControlOutput;
        IF ControlOutput > 0.0 AND CapsuleWeight < (TargetWeight - Tolerance) THEN
            FillingMotor := TRUE;
        ELSE
            FillingMotor := FALSE;
        END_IF;
        
        (* Monitor filling progress *)
        FillingTimer(IN := TRUE);
        WeightDeviation := TargetWeight - CapsuleWeight;
        
        (* Check for successful filling completion *)
        IF CapsuleWeight >= (TargetWeight - Tolerance) AND CapsuleWeight <= (TargetWeight + Tolerance) THEN
            WeightReached := TRUE;
            FillingMotor := FALSE;
            FillingTimer(IN := FALSE);
            FillingComplete := TRUE;
            
            (* Record weight for statistics *)
            WeightArray[ArrayIndex] := CapsuleWeight;
            WeightSum := WeightSum + CapsuleWeight;
            ArrayIndex := ArrayIndex MOD 100 + 1;
            
            (* Calculate average weight *)
            AverageWeight := WeightSum / CycleCounter;
            
            State := STATE_CONVEYING_OUT;
            ConveyOutTimer(IN := TRUE, PT := ConveyOutTime);
            
        (* Check for filling timeout *)
        ELSIF FillingTimer.Q THEN
            FillingTimeoutFlag := TRUE;
            ErrorCode := ERR_FILLING_TIMEOUT;
            FillingMotor := FALSE;
            FillingTimer(IN := FALSE);
            State := STATE_ERROR;
        END_IF;
        
    STATE_CONVEYING_OUT:
        (* Activate conveyor to move filled capsule out *)
        ConveyorMotor := TRUE;
        ConveyOutTimer(IN := TRUE);
        
        IF ConveyOutTimer.Q THEN
            ConveyorMotor := FALSE;
            ConveyOutTimer(IN := FALSE);
            FillingInProgress := FALSE;
            CycleCounter := CycleCounter + 1;
            State := STATE_IDLE;
        END_IF;
        
    STATE_ERROR:
        (* Error State - All motors off *)
        FeederMotor := FALSE;
        FillingMotor := FALSE;
        ConveyorMotor := FALSE;
        FillingInProgress := FALSE;
        
        (* Reset error on manual intervention or condition change *)
        IF NOT EmergencyStopActive AND 
           NOT HopperEmpty AND 
           CapsuleWeight < TargetWeight AND
           CapsuleInPosition THEN
            ErrorCode := ERR_NONE;
            CapsuleDetectFlag := FALSE;
            FillingTimeoutFlag := FALSE;
            OverweightError := FALSE;
            ErrorCounter := ErrorCounter + 1;
            State := STATE_IDLE;
        END_IF;
        
END_CASE;

(* Store previous state for edge detection *)
PreviousState := State;

END_FUNCTION_BLOCK