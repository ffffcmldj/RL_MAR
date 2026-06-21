(* ================================================================ *)
(* CAPSULE FILLING MACHINE CONTROL FUNCTION BLOCK                   *)
(* IEC 61131-3 Structured Text                                     *)
(* Senior PLC Commissioning Engineer - Final Production Code       *)
(* ================================================================ *)

(* --- TYPE DEFINITIONS --- *)
TYPE
    (* State Machine Enumeration *)
    MachineState : (
        STATE_IDLE := 0,
        STATE_CONVEYING_IN := 1,
        STATE_FILLING := 2,
        STATE_CONVEYING_OUT := 3,
        STATE_ERROR := 4
    );
END_TYPE

(* --- FUNCTION BLOCK DEFINITION --- *)
FUNCTION_BLOCK CapsuleFillingMachineControl
VAR_INPUT
    (* Core Process Inputs *)
    CapsuleWeight : REAL;          (* Current capsule weight measurement *)
    TargetWeight : REAL;           (* Target weight to achieve *)
    CapsuleInPosition : BOOL;      (* TRUE when capsule is at filling station *)
    HopperEmpty : BOOL;            (* TRUE when hopper is completely empty *)
    
    (* Extended Inputs for Enhanced Control *)
    StartCycle : BOOL;             (* Rising edge triggers new cycle *)
    ResetErrors : BOOL;            (* Rising edge resets all errors *)
    EmergencyStop : BOOL;          (* Emergency stop input (TRUE = stop) *)
    
    (* Configuration Parameters *)
    WeightTolerance : REAL := 0.005;      (* Acceptable deviation from target *)
    MaxFillingTime : TIME := T#10S;       (* Maximum allowed filling duration *)
    MaxConveyingTime : TIME := T#3S;      (* Maximum conveying time *)
    ConveyingOutTime : TIME := T#1.5S;    (* Time to convey filled capsule out *)
    
    (* PID Controller Parameters *)
    Kp : REAL := 1.0;              (* Proportional gain *)
    Ti : TIME := T#2S;             (* Integral time *)
    Td : TIME := T#0.5S;           (* Derivative time *)
    PID_CycleTime : TIME := T#100MS; (* PID execution cycle *)
END_VAR

VAR_OUTPUT
    (* Primary Motor Controls *)
    FeederMotor : BOOL;            (* Controls material feed to hopper *)
    FillingMotor : BOOL;           (* Controls filling mechanism *)
    ConveyorMotor : BOOL;          (* Controls capsule conveyor *)
    FillingInProgress : BOOL;      (* TRUE during active filling *)
    
    (* Status and Diagnostic Outputs *)
    SystemReady : BOOL;            (* TRUE when system is ready for operation *)
    CycleComplete : BOOL;          (* TRUE when cycle completes successfully *)
    CurrentState : MachineState;   (* Current state machine state *)
    
    (* Error Flags *)
    CapsuleNotDetectedError : BOOL;    (* Capsule not detected in time *)
    FillingTimeoutError : BOOL;        (* Filling took too long *)
    OverweightError : BOOL;            (* Capsule already at/above target *)
    HopperEmptyError : BOOL;           (* Hopper is empty *)
    EmergencyStopActive : BOOL;        (* Emergency stop is active *)
    
    (* Process Monitoring *)
    PIDOutput : REAL;              (* Current PID controller output *)
    WeightDeviation : REAL;        (* Current deviation from target *)
    FillingTimeElapsed : TIME;     (* Time spent in filling state *)
END_VAR

VAR
    (* State Machine Variables *)
    CurrentStateInternal : MachineState := STATE_IDLE;
    PreviousState : MachineState;
    
    (* Timer Instances *)
    ConveyingTimer : TON;
    FillingTimer : TON;
    ConveyingOutTimer : TON;
    CapsuleDetectionTimer : TON;
    
    (* PID Controller *)
    PIDController : PID;
    PID_Enable : BOOL;
    ControlOutput : REAL;
    
    (* Process Flags *)
    CapsuleDetectedFlag : BOOL;
    FillingCompleteFlag : BOOL;
    ConveyingCompleteFlag : BOOL;
    ErrorResetFlag : BOOL;
    CycleStartFlag : BOOL;
    
    (* Error Latches *)
    CapsuleNotDetectedLatch : BOOL;
    FillingTimeoutLatch : BOOL;
    OverweightLatch : BOOL;
    HopperEmptyLatch : BOOL;
    EmergencyStopLatch : BOOL;
    
    (* Edge Detection *)
    StartCycleRisingEdge : R_TRIG;
    ResetErrorsRisingEdge : R_TRIG;
    
    (* Process Variables *)
    InitialWeightCheckPassed : BOOL;
    FillingMotorSpeed : REAL;
    ConveyorMotorSpeed : REAL;
    ActualFillingRate : REAL;
    CapsuleCount : DINT;
    ErrorCount : DINT;
    
    (* Internal Control Variables *)
    SafetyInterlock : BOOL;
    StateMachineEnabled : BOOL;
    ManualOverrideActive : BOOL;
END_VAR

(* ================================================================ *)
(* MAIN LOGIC - EXECUTED EVERY CYCLE                               *)
(* ================================================================ *)

(* --- Edge Detection for Control Signals --- *)
StartCycleRisingEdge(CLK := StartCycle);
ResetErrorsRisingEdge(CLK := ResetErrors);

(* --- Safety Interlock Calculation --- *)
SafetyInterlock := NOT HopperEmpty AND NOT EmergencyStop;
StateMachineEnabled := SafetyInterlock AND NOT ManualOverrideActive;

(* --- Error Reset Logic --- *)
IF ResetErrorsRisingEdge.Q THEN
    CapsuleNotDetectedLatch := FALSE;
    FillingTimeoutLatch := FALSE;
    OverweightLatch := FALSE;
    HopperEmptyLatch := FALSE;
    EmergencyStopLatch := FALSE;
    ErrorResetFlag := TRUE;
ELSE
    ErrorResetFlag := FALSE;
END_IF;

(* --- Emergency Stop Handling --- *)
IF EmergencyStop THEN
    EmergencyStopLatch := TRUE;
    CurrentStateInternal := STATE_IDLE;
END_IF;

(* --- Hopper Empty Error Latch --- *)
IF HopperEmpty THEN
    HopperEmptyLatch := TRUE;
END_IF;

(* --- System Ready Status --- *)
SystemReady := SafetyInterlock AND 
               (CurrentStateInternal = STATE_IDLE) AND 
               NOT EmergencyStopLatch AND 
               NOT HopperEmptyLatch;

(* --- Cycle Start Flag --- *)
IF StartCycleRisingEdge.Q AND SystemReady THEN
    CycleStartFlag := TRUE;
ELSE
    CycleStartFlag := FALSE;
END_IF;

(* --- CRITICAL SAFETY CHECKS --- *)
(* 1. Hopper Empty Check - Immediate Safety Shutdown *)
IF HopperEmpty THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    CycleComplete := FALSE;
    HopperEmptyError := TRUE;
    CurrentStateInternal := STATE_IDLE;
    RETURN;
END_IF;

(* 2. Emergency Stop Check *)
IF EmergencyStop THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    CycleComplete := FALSE;
    EmergencyStopActive := TRUE;
    CurrentStateInternal := STATE_IDLE;
    RETURN;
END_IF;

(* 3. Initial Weight Validation *)
IF CapsuleWeight >= TargetWeight THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    CycleComplete := FALSE;
    OverweightError := TRUE;
    OverweightLatch := TRUE;
    CurrentStateInternal := STATE_IDLE;
    RETURN;
END_IF;

(* --- STATE MACHINE EXECUTION --- *)
CASE CurrentStateInternal OF
    STATE_IDLE:
        (* Initialization and Waiting State *)
        FeederMotor := TRUE;                    (* Keep feeder running *)
        FillingMotor := FALSE;
        ConveyorMotor := FALSE;
        FillingInProgress := FALSE;
        CycleComplete := FALSE;
        PID_Enable := FALSE;
        
        (* Reset process flags *)
        CapsuleDetectedFlag := FALSE;
        FillingCompleteFlag := FALSE;
        ConveyingCompleteFlag := FALSE;
        
        (* Reset timers *)
        ConveyingTimer(IN := FALSE, PT := MaxConveyingTime);
        FillingTimer(IN := FALSE, PT := MaxFillingTime);
        ConveyingOutTimer(IN := FALSE, PT := ConveyingOutTime);
        CapsuleDetectionTimer(IN := FALSE, PT := MaxConveyingTime);
        
        (* Transition Conditions *)
        IF CycleStartFlag AND CapsuleInPosition THEN
            CapsuleDetectedFlag := TRUE;
            CurrentStateInternal := STATE_CONVEYING_IN;
        ELSIF CycleStartFlag THEN
            (* Start capsule detection timer *)
            CapsuleDetectionTimer(IN := TRUE, PT := MaxConveyingTime);
            CurrentStateInternal := STATE_CONVEYING_IN;
        END_IF;
        
    STATE_CONVEYING_IN:
        (* Move capsule to filling position *)
        ConveyorMotor := TRUE;
        FeederMotor := TRUE;
        FillingInProgress := FALSE;
        
        (* Start conveying timer *)
        ConveyingTimer(IN := TRUE, PT := MaxConveyingTime);
        
        (* Monitor for capsule detection *)
        IF CapsuleInPosition THEN
            CapsuleDetectedFlag := TRUE;
            CapsuleDetectionTimer(IN := FALSE, PT := MaxConveyingTime);
        END_IF;
        
        (* Transition Conditions *)
        IF CapsuleDetectedFlag THEN
            ConveyingTimer(IN := FALSE, PT := MaxConveyingTime);
            CurrentStateInternal := STATE_FILLING;
        ELSIF ConveyingTimer.Q THEN
            (* Timeout - capsule not detected *)
            CapsuleNotDetectedError := TRUE;
            CapsuleNotDetectedLatch := TRUE;
            CurrentStateInternal := STATE_ERROR;
        END_IF;
        
    STATE_FILLING:
        (* Precise Filling with PID Control *)
        ConveyorMotor := FALSE;
        FeederMotor := TRUE;
        FillingInProgress := TRUE;
        CycleComplete := FALSE;
        
        (* Enable PID Controller *)
        PID_Enable := TRUE;
        
        (* Configure and Execute PID *)
        PIDController.Kp := Kp;
        PIDController.Ti := Ti;
        PIDController.Td := Td;
        PIDController.Cycle := PID_CycleTime;
        
        PIDController.SP := TargetWeight;
        PIDController.PV := CapsuleWeight;
        PIDController.Enable := PID_Enable;
        PIDController.Execute();
        
        ControlOutput := PIDController.CO;
        PIDOutput := ControlOutput;
        
        (* Control Filling Motor based on PID output *)
        IF ControlOutput > 0.0 AND CapsuleWeight < TargetWeight THEN
            FillingMotor := TRUE;
            FillingMotorSpeed := ControlOutput;
        ELSE
            FillingMotor := FALSE;
            FillingMotorSpeed := 0.0;
        END_IF;
        
        (* Start filling timeout timer *)
        FillingTimer(IN := TRUE, PT := MaxFillingTime);
        FillingTimeElapsed := FillingTimer.ET;
        
        (* Calculate weight deviation *)
        WeightDeviation := TargetWeight - CapsuleWeight;
        
        (* Check for filling completion *)
        IF ABS(WeightDeviation) <= WeightTolerance THEN
            FillingCompleteFlag := TRUE;
            FillingMotor := FALSE;
            PID_Enable := FALSE;
            FillingTimer(IN := FALSE, PT := MaxFillingTime);
            CurrentStateInternal := STATE_CONVEYING_OUT;
        ELSIF FillingTimer.Q THEN
            (* Filling timeout error *)
            FillingTimeoutError := TRUE;
            FillingTimeoutLatch := TRUE;
            FillingMotor := FALSE;
            PID_Enable := FALSE;
            CurrentStateInternal := STATE_ERROR;
        END_IF;
        
    STATE_CONVEYING_OUT:
        (* Move filled capsule out of station *)
        FillingInProgress := FALSE;
        FillingMotor := FALSE;
        ConveyorMotor := TRUE;
        FeederMotor := TRUE;
        
        (* Start conveying out timer *)
        ConveyingOutTimer(IN := TRUE, PT := ConveyingOutTime);
        
        (* Transition Conditions *)
        IF ConveyingOutTimer.Q THEN
            ConveyorMotor := FALSE;
            CycleComplete := TRUE;
            CapsuleCount := CapsuleCount + 1;
            CurrentStateInternal := STATE_IDLE;
        END_IF;
        
    STATE_ERROR:
        (* Error State - All Motors Off *)
        FeederMotor := FALSE;
        FillingMotor := FALSE;
        ConveyorMotor := FALSE;
        FillingInProgress := FALSE;
        CycleComplete := FALSE;
        PID_Enable := FALSE;
        
        (* Reset timers *)
        ConveyingTimer(IN := FALSE, PT := MaxConveyingTime);
        FillingTimer(IN := FALSE, PT := MaxFillingTime);
        ConveyingOutTimer(IN := FALSE, PT := ConveyingOutTime);
        
        (* Wait for error reset *)
        IF ErrorResetFlag THEN
            CurrentStateInternal := STATE_IDLE;
        END_IF;
        
END_CASE;

(* --- Update Public State Output --- *)
CurrentState := CurrentStateInternal;

(* --- Update Previous State for Diagnostics --- *)
PreviousState := CurrentStateInternal;

(* --- Calculate Actual Filling Rate --- *)
IF FillingInProgress AND FillingTimeElapsed > T#0S THEN
    ActualFillingRate := CapsuleWeight / TIME_TO_REAL(FillingTimeElapsed);
ELSE
    ActualFillingRate := 0.0;
END_IF;

(* --- Update Error Count --- *)
ErrorCount := DINT_TO_DINT(CapsuleNotDetectedLatch) + 
              DINT_TO_DINT(FillingTimeoutLatch) + 
              DINT_TO_DINT(OverweightLatch) + 
              DINT_TO_DINT(HopperEmptyLatch) + 
              DINT_TO_DINT(EmergencyStopLatch);

END_FUNCTION_BLOCK