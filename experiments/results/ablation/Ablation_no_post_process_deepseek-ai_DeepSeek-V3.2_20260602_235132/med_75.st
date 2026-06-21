(*
    Home Brewing System PLC Program
    FUNCTION_BLOCK: HomeBrewingSystem
    Description: Controls an automatic home brewing system with temperature control,
                 agitation based on water flow, and timed events for hops dispensing
                 and fermentation tank transfer.
    IEC 61131-3 Structured Text
*)

(* Custom Data Types *)
TYPE
    (* Process Stages Enumeration *)
    ProcessStage : (
        STAGE_IDLE := 0,
        STAGE_BREWING := 1,
        STAGE_HOPS_DISPENSED := 2,
        STAGE_FERMENTATION_READY := 3,
        STAGE_COMPLETE := 4
    );
    
    (* System Status Enumeration *)
    SystemStatus : (
        STATUS_DISABLED := 0,
        STATUS_READY := 1,
        STATUS_BREWING := 2,
        STATUS_ERROR := 3
    );
    
    (* Event Log Entry Structure *)
    EventLogEntry :
        STRUCT
            TimeStamp : TIME;
            EventCode : INT;
            Description : STRING(50);
        END_STRUCT;
END_TYPE

(*
    FUNCTION_BLOCK: HomeBrewingSystem
    Main control logic for the home brewing system
*)
FUNCTION_BLOCK HomeBrewingSystem
VAR_INPUT
    (* Primary Process Inputs *)
    TemperatureSensor : REAL;        (* Current temperature in °C *)
    WaterFlowSensor : REAL;          (* Current water flow in L/min *)
    BrewingStartTime : TIME;         (* Absolute start time of brewing process *)
    BrewingDuration : TIME;          (* Total brewing duration *)
    
    (* Configuration Parameters *)
    TemperatureSetpoint : REAL := 65.0;      (* Target brewing temperature *)
    FlowThreshold : REAL := 0.5;             (* Flow threshold for agitation *)
    HopsDispenseDelay : TIME := T#5h;        (* Time delay for hops dispensing *)
    FermentationDelay : TIME := T#48h;       (* Time delay for fermentation transfer *)
    TemperatureDeadband : REAL := 0.5;       (* Hysteresis for temperature control *)
    FlowDeadband : REAL := 0.1;              (* Hysteresis for flow control *)
    
    (* System Control Inputs *)
    SystemEnable : BOOL := TRUE;             (* Master enable for the system *)
    EmergencyStop : BOOL := FALSE;           (* Emergency stop input *)
    ManualHeatingOverride : BOOL := FALSE;   (* Manual heating control override *)
    ManualAgitationOverride : BOOL := FALSE; (* Manual agitation control override *)
    
    (* Calibration Offsets *)
    TemperatureCalibration : REAL := 0.0;    (* Temperature sensor calibration offset *)
    FlowCalibration : REAL := 0.0;           (* Flow sensor calibration offset *)
END_VAR

VAR_OUTPUT
    (* Primary Control Outputs *)
    HeatingElement : BOOL;           (* Control signal for heating element *)
    AgitationMotor : BOOL;           (* Control signal for agitation motor *)
    HopsDispenser : BOOL;            (* Control signal for hops dispenser *)
    FermentationTank : BOOL;         (* Control signal for fermentation tank transfer *)
    
    (* System Status Outputs *)
    SystemStatus : SystemStatus;     (* Current system status *)
    ProcessStage : ProcessStage;     (* Current process stage *)
    TemperatureAlarm : BOOL;         (* Temperature out of range alarm *)
    FlowAlarm : BOOL;                (* Flow out of range alarm *)
    
    (* Process Information *)
    ElapsedBrewingTime : TIME;       (* Time elapsed since brewing start *)
    TemperatureCorrected : REAL;      (* Calibrated temperature reading *)
    FlowCorrected : REAL;            (* Calibrated flow reading *)
    HopsDispenseReady : BOOL;        (* Indicates hops dispense is ready *)
    FermentationReady : BOOL;        (* Indicates fermentation transfer is ready *)
END_VAR

VAR
    (* Internal State Variables *)
    bHopsDispensed : BOOL := FALSE;          (* Flag to ensure single hops dispense *)
    bFermentationTriggered : BOOL := FALSE;  (* Flag to ensure single fermentation transfer *)
    bHeatingElementState : BOOL := FALSE;    (* Internal heating element state *)
    bAgitationMotorState : BOOL := FALSE;    (* Internal agitation motor state *)
    
    (* Process Timing Variables *)
    tCurrentTime : TIME;                     (* Current system time *)
    tElapsedTime : TIME;                     (* Elapsed brewing time *)
    tHopsDispenseTime : TIME;                (* Calculated hops dispense time *)
    tFermentationTime : TIME;                (* Calculated fermentation time *)
    
    (* Sensor Processing *)
    rTemperatureUpperLimit : REAL;           (* Upper temperature limit for deadband *)
    rTemperatureLowerLimit : REAL;           (* Lower temperature limit for deadband *)
    rFlowUpperThreshold : REAL;              (* Upper flow threshold for deadband *)
    rFlowLowerThreshold : REAL;              (* Lower flow threshold for deadband *)
    
    (* Safety and Interlocks *)
    bSafetyInterlock : BOOL := TRUE;         (* Safety interlock status *)
    bHeatingAllowed : BOOL := TRUE;          (* Heating permission flag *)
    bAgitationAllowed : BOOL := TRUE;        (* Agitation permission flag *)
    
    (* Event Logging *)
    aEventLog : ARRAY[1..50] OF EventLogEntry;  (* Circular buffer for event logging *)
    nLogIndex : INT := 1;                       (* Current log index *)
    
    (* Timers *)
    tmrHopsDispense : TON;                   (* Timer for hops dispense duration *)
    tmrFermentation : TON;                   (* Timer for fermentation transfer duration *)
END_VAR

(*
    Main Program Logic
*)

(* 1. Initialization and Safety Checks *)
(* Calculate deadband limits *)
rTemperatureUpperLimit := TemperatureSetpoint + (TemperatureDeadband / 2);
rTemperatureLowerLimit := TemperatureSetpoint - (TemperatureDeadband / 2);
rFlowUpperThreshold := FlowThreshold + (FlowDeadband / 2);
rFlowLowerThreshold := FlowThreshold - (FlowDeadband / 2);

(* Apply sensor calibration *)
TemperatureCorrected := TemperatureSensor + TemperatureCalibration;
FlowCorrected := WaterFlowSensor + FlowCalibration;

(* Get current system time *)
tCurrentTime := TIME();

(* Calculate elapsed brewing time *)
IF BrewingStartTime > T#0s THEN
    tElapsedTime := tCurrentTime - BrewingStartTime;
    
    (* Ensure elapsed time doesn't exceed brewing duration *)
    IF tElapsedTime > BrewingDuration THEN
        tElapsedTime := BrewingDuration;
    END_IF;
ELSE
    tElapsedTime := T#0s;
END_IF;

ElapsedBrewingTime := tElapsedTime;

(* Calculate event times *)
tHopsDispenseTime := HopsDispenseDelay;
tFermentationTime := FermentationDelay;

(* 2. Safety and System Status Management *)
(* Emergency stop handling *)
IF EmergencyStop THEN
    bSafetyInterlock := FALSE;
    SystemStatus := STATUS_ERROR;
ELSIF NOT SystemEnable THEN
    bSafetyInterlock := FALSE;
    SystemStatus := STATUS_DISABLED;
ELSE
    bSafetyInterlock := TRUE;
    
    (* Determine system status based on brewing state *)
    IF BrewingStartTime = T#0s THEN
        SystemStatus := STATUS_READY;
        ProcessStage := STAGE_IDLE;
    ELSIF tElapsedTime < BrewingDuration THEN
        SystemStatus := STATUS_BREWING;
        
        (* Update process stage *)
        IF tElapsedTime >= tFermentationTime THEN
            ProcessStage := STAGE_FERMENTATION_READY;
        ELSIF tElapsedTime >= tHopsDispenseTime THEN
            ProcessStage := STAGE_HOPS_DISPENSED;
        ELSE
            ProcessStage := STAGE_BREWING;
        END_IF;
    ELSE
        SystemStatus := STATUS_READY;
        ProcessStage := STAGE_COMPLETE;
    END_IF;
END_IF;

(* 3. Temperature Control Logic *)
(* Check temperature alarm condition *)
TemperatureAlarm := (TemperatureCorrected > (TemperatureSetpoint + 5.0)) OR 
                    (TemperatureCorrected < (TemperatureSetpoint - 5.0));

(* Determine heating permission *)
bHeatingAllowed := bSafetyInterlock AND 
                   (SystemStatus = STATUS_BREWING) AND 
                   NOT TemperatureAlarm;

(* Temperature control with deadband *)
IF bHeatingAllowed THEN
    IF ManualHeatingOverride THEN
        bHeatingElementState := TRUE;
    ELSE
        (* Hysteresis control *)
        IF TemperatureCorrected < rTemperatureLowerLimit THEN
            bHeatingElementState := TRUE;
        ELSIF TemperatureCorrected > rTemperatureUpperLimit THEN
            bHeatingElementState := FALSE;
        END_IF;
        (* State persists between thresholds *)
    END_IF;
ELSE
    bHeatingElementState := FALSE;
END_IF;

(* 4. Flow Control Logic *)
(* Check flow alarm condition *)
FlowAlarm := (FlowCorrected > (FlowThreshold * 3.0)) OR 
             (FlowCorrected < 0.0);

(* Determine agitation permission *)
bAgitationAllowed := bSafetyInterlock AND 
                     (SystemStatus = STATUS_BREWING) AND 
                     NOT FlowAlarm;

(* Flow control with deadband *)
IF bAgitationAllowed THEN
    IF ManualAgitationOverride THEN
        bAgitationMotorState := TRUE;
    ELSE
        (* Hysteresis control *)
        IF FlowCorrected > rFlowUpperThreshold THEN
            bAgitationMotorState := TRUE;
        ELSIF FlowCorrected < rFlowLowerThreshold THEN
            bAgitationMotorState := FALSE;
        END_IF;
        (* State persists between thresholds *)
    END_IF;
ELSE
    bAgitationMotorState := FALSE;
END_IF;

(* 5. Timed Event Control *)
(* Hops dispense control *)
IF (SystemStatus = STATUS_BREWING) AND 
   (tElapsedTime >= tHopsDispenseTime) AND 
   (NOT bHopsDispensed) THEN
    
    HopsDispenseReady := TRUE;
    
    (* Activate dispenser for 10 seconds *)
    tmrHopsDispense(IN := TRUE, PT := T#10s);
    
    IF tmrHopsDispense.Q THEN
        HopsDispenser := FALSE;
        bHopsDispensed := TRUE;
        tmrHopsDispense(IN := FALSE);
    ELSE
        HopsDispenser := TRUE;
    END_IF;
ELSE
    HopsDispenser := FALSE;
    HopsDispenseReady := FALSE;
    tmrHopsDispense(IN := FALSE);
END_IF;

(* Fermentation tank transfer control *)
IF (SystemStatus = STATUS_BREWING) AND 
   (tElapsedTime >= tFermentationTime) AND 
   (NOT bFermentationTriggered) THEN
    
    FermentationReady := TRUE;
    
    (* Activate transfer for 30 seconds *)
    tmrFermentation(IN := TRUE, PT := T#30s);
    
    IF tmrFermentation.Q THEN
        FermentationTank := FALSE;
        bFermentationTriggered := TRUE;
        tmrFermentation(IN := FALSE);
    ELSE
        FermentationTank := TRUE;
    END_IF;
ELSE
    FermentationTank := FALSE;
    FermentationReady := FALSE;
    tmrFermentation(IN := FALSE);
END_IF;

(* 6. Apply Safety Interlocks and Set Outputs *)
(* Apply final safety checks before setting outputs *)
IF bSafetyInterlock THEN
    HeatingElement := bHeatingElementState;
    AgitationMotor := bAgitationMotorState;
    
    (* Safety interlock: Prevent simultaneous heating and agitation *)
    IF bHeatingElementState AND bAgitationMotorState THEN
        AgitationMotor := FALSE;
    END_IF;
    
    (* Safety interlock: Prevent simultaneous hops dispense and fermentation transfer *)
    IF HopsDispenser AND FermentationTank THEN
        FermentationTank := FALSE;
    END_IF;
ELSE
    (* Emergency or disabled state - all outputs off *)
    HeatingElement := FALSE;
    AgitationMotor := FALSE;
    HopsDispenser := FALSE;
    FermentationTank := FALSE;
END_IF;

(* 7. Event Logging *)
(* Log significant state changes *)
IF (SystemStatus = STATUS_BREWING) AND (tElapsedTime = T#0s) THEN
    (* Log brewing start *)
    aEventLog[nLogIndex].TimeStamp := tCurrentTime;
    aEventLog[nLogIndex].EventCode := 100;
    aEventLog[nLogIndex].Description := 'Brewing process started';
    nLogIndex := nLogIndex MOD 50 + 1;
END_IF;

IF bHopsDispensed AND (HopsDispenser = FALSE) THEN
    (* Log hops dispensed *)
    aEventLog[nLogIndex].TimeStamp := tCurrentTime;
    aEventLog[nLogIndex].EventCode := 200;
    aEventLog[nLogIndex].Description := 'Hops dispensed';
    nLogIndex := nLogIndex MOD 50 + 1;
END_IF;

IF bFermentationTriggered AND (FermentationTank = FALSE) THEN
    (* Log fermentation transfer *)
    aEventLog[nLogIndex].TimeStamp := tCurrentTime;
    aEventLog[nLogIndex].EventCode := 300;
    aEventLog[nLogIndex].Description := 'Fermentation transfer completed';
    nLogIndex := nLogIndex MOD 50 + 1;
END_IF;

END_FUNCTION_BLOCK;