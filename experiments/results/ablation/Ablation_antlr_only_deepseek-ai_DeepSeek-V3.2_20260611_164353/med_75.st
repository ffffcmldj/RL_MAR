TYPE
    // State enumeration for process phases
    ProcessPhase : (
        IDLE,
        HEATING,
        BREWING,
        HOP_ADDITION,
        FERMENTATION_TRANSFER,
        COMPLETE,
        FAULT
    );
    
    // Status enumeration for temperature and flow
    SensorStatus : (
        NORMAL,
        LOW,
        HIGH,
        FAULT
    );
END_TYPE

FUNCTION_BLOCK HomeBrewingSystem
VAR_INPUT
    // Primary process inputs
    TemperatureSensor : REAL;        (* Current temperature in °C *)
    WaterFlowSensor : REAL;         (* Current flow rate in L/min *)
    BrewingStartTime : TIME;        (* Absolute start time of brewing process *)
    BrewingDuration : TIME;         (* Total brewing duration *)
    
    // Control inputs
    SystemEnable : BOOL;            (* Master enable for the system *)
    EmergencyStop : BOOL;           (* Emergency stop - overrides all outputs *)
    
    // Calibration inputs
    TemperatureCalibrationOffset : REAL := 0.0;  (* Temperature sensor offset *)
    FlowCalibrationFactor : REAL := 1.0;         (* Flow sensor calibration factor *)
    
    // Configuration inputs
    TemperatureSetpoint : REAL := 65.0;          (* Target brewing temperature *)
    TemperatureDeadband : REAL := 0.5;           (* Hysteresis for temperature control *)
    FlowThreshold : REAL := 0.5;                 (* Flow threshold for agitation *)
    FlowDeadband : REAL := 0.1;                  (* Hysteresis for flow control *)
    HopsDispenseDelay : TIME := T#5h;            (* Time delay for hops addition *)
    FermentationDelay : TIME := T#48h;           (* Time delay for fermentation transfer *)
    
    // Manual overrides
    ManualHeatingOverride : BOOL;                (* Manual heating control *)
    ManualAgitationOverride : BOOL;              (* Manual agitation control *)
END_VAR

VAR_OUTPUT
    // Primary control outputs
    HeatingElement : BOOL;           (* Control signal for heating element *)
    AgitationMotor : BOOL;           (* Control signal for agitation motor *)
    HopsDispenser : BOOL;            (* Control signal for hops dispenser *)
    FermentationTank : BOOL;         (* Control signal for fermentation tank transfer *)
    
    // Status outputs
    SystemStatus : INT;              (* Overall system status *)
    TemperatureStatus : INT;         (* Temperature sensor status *)
    FlowStatus : INT;                (* Flow sensor status *)
    ProcessPhase : INT;              (* Current process phase *)
    
    // Diagnostic outputs
    TemperatureAlarm : BOOL;         (* Temperature out of range alarm *)
    FlowAlarm : BOOL;                (* Flow out of range alarm *)
    BrewingElapsedTime : TIME;       (* Elapsed brewing time *)
END_VAR

VAR
    // Internal state variables
    BrewingActive : BOOL;            (* Flag indicating brewing is active *)
    HopsDispensedFlag : BOOL;        (* Flag indicating hops have been dispensed *)
    FermentationInitiatedFlag : BOOL; (* Flag indicating transfer has been initiated *)
    
    // Timing variables
    CurrentSystemTime : TIME;        (* Current system time *)
    BrewingElapsed : TIME;           (* Elapsed brewing time *)
    HopsDispenseTimer : TON;         (* Timer for hops dispensing *)
    FermentationTimer : TON;         (* Timer for fermentation transfer *)
    
    // Process variables
    TemperatureFiltered : REAL;      (* Filtered temperature reading *)
    FlowFiltered : REAL;             (* Filtered flow reading *)
    TemperatureSetpointInternal : REAL;  (* Internal setpoint with calibration *)
    FlowThresholdInternal : REAL;    (* Internal threshold with calibration *)
    
    // Safety and fault detection
    TemperatureSensorFault : BOOL;   (* Temperature sensor fault flag *)
    FlowSensorFault : BOOL;          (* Flow sensor fault flag *)
    SafetyInterlock : BOOL;          (* Safety interlock status *)
    
    // Process state
    CurrentPhase : ProcessPhase;     (* Current process phase *)
    
    // Configuration constants
    MIN_TEMPERATURE : REAL := 0.0;   (* Minimum valid temperature *)
    MAX_TEMPERATURE : REAL := 100.0; (* Maximum valid temperature *)
    MIN_FLOW : REAL := 0.0;          (* Minimum valid flow *)
    MAX_FLOW : REAL := 10.0;         (* Maximum valid flow *)
    
    // Filter constants
    TEMP_FILTER_FACTOR : REAL := 0.1;    (* Temperature filter factor *)
    FLOW_FILTER_FACTOR : REAL := 0.1;    (* Flow filter factor *)
END_VAR

// Main logic body
VAR_TEMP
    TempElapsedTime : TIME;
    TempHeatingRequired : BOOL;
    TempAgitationRequired : BOOL;
    TempHopsDispenseRequired : BOOL;
    TempFermentationRequired : BOOL;
END_VAR

// 1. Initialize and update system time
CurrentSystemTime := TIME();  // Get current system time

// 2. Apply calibration to sensor readings
TemperatureSetpointInternal := TemperatureSetpoint + TemperatureCalibrationOffset;
FlowThresholdInternal := FlowThreshold * FlowCalibrationFactor;

// 3. Apply simple low-pass filtering to sensor readings
TemperatureFiltered := TemperatureFiltered + TEMP_FILTER_FACTOR * 
                      (TemperatureSensor - TemperatureFiltered);
FlowFiltered := FlowFiltered + FLOW_FILTER_FACTOR * 
               (WaterFlowSensor - FlowFiltered);

// 4. Sensor validation and fault detection
TemperatureSensorFault := (TemperatureFiltered < MIN_TEMPERATURE) OR 
                         (TemperatureFiltered > MAX_TEMPERATURE);
FlowSensorFault := (FlowFiltered < MIN_FLOW) OR 
                  (FlowFiltered > MAX_FLOW);

// 5. Determine sensor status
IF TemperatureSensorFault THEN
    TemperatureStatus := SensorStatus.FAULT;
ELSIF TemperatureFiltered < (TemperatureSetpointInternal - 10.0) THEN
    TemperatureStatus := SensorStatus.LOW;
ELSIF TemperatureFiltered > (TemperatureSetpointInternal + 10.0) THEN
    TemperatureStatus := SensorStatus.HIGH;
ELSE
    TemperatureStatus := SensorStatus.NORMAL;
END_IF;

IF FlowSensorFault THEN
    FlowStatus := SensorStatus.FAULT;
ELSIF FlowFiltered < (FlowThresholdInternal - 0.2) THEN
    FlowStatus := SensorStatus.LOW;
ELSIF FlowFiltered > (FlowThresholdInternal + 2.0) THEN
    FlowStatus := SensorStatus.HIGH;
ELSE
    FlowStatus := SensorStatus.NORMAL;
END_IF;

// 6. Calculate elapsed brewing time
IF BrewingStartTime > T#0s THEN
    TempElapsedTime := CurrentSystemTime - BrewingStartTime;
    
    // Ensure elapsed time doesn't exceed duration
    IF TempElapsedTime > BrewingDuration THEN
        BrewingElapsed := BrewingDuration;
    ELSE
        BrewingElapsed := TempElapsedTime;
    END_IF;
ELSE
    BrewingElapsed := T#0s;
END_IF;

BrewingElapsedTime := BrewingElapsed;  // Output elapsed time

// 7. Determine if brewing is active
BrewingActive := (BrewingStartTime > T#0s) AND 
                (BrewingElapsed < BrewingDuration) AND 
                NOT EmergencyStop AND 
                SystemEnable;

// 8. Process phase determination
IF EmergencyStop THEN
    CurrentPhase := ProcessPhase.FAULT;
ELSIF NOT SystemEnable THEN
    CurrentPhase := ProcessPhase.IDLE;
ELSIF NOT BrewingActive THEN
    IF BrewingElapsed >= BrewingDuration THEN
        CurrentPhase := ProcessPhase.COMPLETE;
    ELSE
        CurrentPhase := ProcessPhase.IDLE;
    END_IF;
ELSE
    // Determine phase based on elapsed time
    IF BrewingElapsed >= FermentationDelay THEN
        CurrentPhase := ProcessPhase.FERMENTATION_TRANSFER;
    ELSIF BrewingElapsed >= HopsDispenseDelay THEN
        CurrentPhase := ProcessPhase.HOP_ADDITION;
    ELSIF TemperatureFiltered >= (TemperatureSetpointInternal - TemperatureDeadband) THEN
        CurrentPhase := ProcessPhase.BREWING;
    ELSE
        CurrentPhase := ProcessPhase.HEATING;
    END_IF;
END_IF;

ProcessPhase := CurrentPhase;  // Output current phase

// 9. Heating element control with hysteresis
TempHeatingRequired := FALSE;

IF BrewingActive AND NOT TemperatureSensorFault THEN
    IF ManualHeatingOverride THEN
        TempHeatingRequired := TRUE;
    ELSIF TemperatureFiltered < (TemperatureSetpointInternal - TemperatureDeadband) THEN
        TempHeatingRequired := TRUE;
    ELSIF TemperatureFiltered >= TemperatureSetpointInternal THEN
        TempHeatingRequired := FALSE;
    END_IF;
END_IF;

HeatingElement := TempHeatingRequired AND NOT EmergencyStop;

// 10. Agitation motor control with hysteresis
TempAgitationRequired := FALSE;

IF BrewingActive AND NOT FlowSensorFault THEN
    IF ManualAgitationOverride THEN
        TempAgitationRequired := TRUE;
    ELSIF FlowFiltered > (FlowThresholdInternal + FlowDeadband) THEN
        TempAgitationRequired := TRUE;
    ELSIF FlowFiltered <= (FlowThresholdInternal - FlowDeadband) THEN
        TempAgitationRequired := FALSE;
    END_IF;
END_IF;

AgitationMotor := TempAgitationRequired AND NOT EmergencyStop;

// 11. Hops dispenser control
TempHopsDispenseRequired := FALSE;

IF BrewingActive AND (CurrentPhase = ProcessPhase.HOP_ADDITION) THEN
    // Use timer to ensure proper dispensing duration
    HopsDispenseTimer(
        IN := NOT HopsDispensedFlag,
        PT := T#10s,  // Dispense for 10 seconds
        Q => TempHopsDispenseRequired
    );
    
    IF HopsDispenseTimer.Q THEN
        HopsDispensedFlag := TRUE;
    END_IF;
ELSE
    HopsDispenseTimer(IN := FALSE);
END_IF;

HopsDispenser := TempHopsDispenseRequired AND NOT EmergencyStop;

// 12. Fermentation tank control
TempFermentationRequired := FALSE;

IF BrewingActive AND (CurrentPhase = ProcessPhase.FERMENTATION_TRANSFER) THEN
    // Use timer to ensure proper transfer duration
    FermentationTimer(
        IN := NOT FermentationInitiatedFlag,
        PT := T#30s,  // Transfer for 30 seconds
        Q => TempFermentationRequired
    );
    
    IF FermentationTimer.Q THEN
        FermentationInitiatedFlag := TRUE;
    END_IF;
ELSE
    FermentationTimer(IN := FALSE);
END_IF;

FermentationTank := TempFermentationRequired AND NOT EmergencyStop;

// 13. Alarm generation
TemperatureAlarm := (TemperatureStatus = SensorStatus.FAULT) OR 
                   (TemperatureStatus = SensorStatus.HIGH) OR 
                   (TemperatureStatus = SensorStatus.LOW);
FlowAlarm := (FlowStatus = SensorStatus.FAULT) OR 
            (FlowStatus = SensorStatus.HIGH) OR 
            (FlowStatus = SensorStatus.LOW);

// 14. System status output
IF EmergencyStop THEN
    SystemStatus := -1;  // Emergency stop active
ELSIF TemperatureSensorFault OR FlowSensorFault THEN
    SystemStatus := -2;  // Sensor fault
ELSIF NOT SystemEnable THEN
    SystemStatus := 0;   // System disabled
ELSIF CurrentPhase = ProcessPhase.IDLE THEN
    SystemStatus := 1;   // System idle
ELSIF CurrentPhase = ProcessPhase.HEATING THEN
    SystemStatus := 2;   // Heating phase
ELSIF CurrentPhase = ProcessPhase.BREWING THEN
    SystemStatus := 3;   // Brewing phase
ELSIF CurrentPhase = ProcessPhase.HOP_ADDITION THEN
    SystemStatus := 4;   // Hop addition phase
ELSIF CurrentPhase = ProcessPhase.FERMENTATION_TRANSFER THEN
    SystemStatus := 5;   // Fermentation transfer phase
ELSIF CurrentPhase = ProcessPhase.COMPLETE THEN
    SystemStatus := 6;   // Process complete
ELSE
    SystemStatus := 99;  // Unknown state
END_IF;

// 15. Reset flags when brewing is not active
IF NOT BrewingActive THEN
    HopsDispensedFlag := FALSE;
    FermentationInitiatedFlag := FALSE;
END_IF;

END_FUNCTION_BLOCK;