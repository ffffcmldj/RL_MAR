TYPE
    // System status enumeration
    HVAC_SystemStatus : (
        STATUS_OFF := 0,
        STATUS_STANDBY,
        STATUS_HEATING,
        STATUS_COOLING,
        STATUS_VENTILATING,
        STATUS_FAULT
    );
    
    // Alarm status bits
    HVAC_AlarmBits : STRUCT
        TemperatureSensorFault : BOOL;
        HumiditySensorFault : BOOL;
        HeatingFault : BOOL;
        CoolingFault : BOOL;
        VentilationFault : BOOL;
        MaintenanceRequired : BOOL;
        _reserved : ARRAY[0..8] OF BOOL;
    END_STRUCT;
END_TYPE

FUNCTION_BLOCK SmartHVACSystem
VAR_INPUT
    // Primary sensor inputs
    TemperatureSensor : REAL; (* Raw temperature reading in °C *)
    HumiditySensor : REAL; (* Raw humidity reading in % *)
    
    // Configuration inputs
    DesiredTemperature : REAL := 24.0; (* Temperature setpoint *)
    DesiredHumidity : REAL := 50.0; (* Humidity setpoint *)
    TemperatureThreshold : REAL := 1.0; (* Temperature deadband *)
    HumidityThreshold : REAL := 5.0; (* Humidity deadband *)
    
    // Calibration inputs
    TemperatureCalibrationOffset : REAL := 0.0; (* Temperature calibration *)
    HumidityCalibrationOffset : REAL := 0.0; (* Humidity calibration *)
    
    // Control inputs
    ManualOverride : BOOL := FALSE; (* Manual override active *)
    ModeOverride : INT := 0; (* Manual mode: 0=Off, 1=Cooling, 2=Heating, 3=Ventilation *)
    FanSpeedOverride : INT := 0; (* Manual fan speed *)
    EmergencyStop : BOOL := FALSE; (* Emergency stop command *)
    
    // Hysteresis configuration
    TemperatureHysteresis : REAL := 0.5; (* Prevents rapid mode switching *)
    HumidityHysteresis : REAL := 2.0; (* Prevents rapid ventilation cycling *)
    
    // Timing configuration
    ModeChangeDelayTime : TIME := T#2s; (* Minimum time between mode changes *)
    SensorFilterTime : TIME := T#5s; (* Sensor filtering time constant *)
END_VAR

VAR_OUTPUT
    // Control outputs
    HVACMode : INT := 0; (* 0=Off, 1=Cooling, 2=Heating, 3=Ventilation *)
    HVACFanSpeed : INT := 0; (* 0=Off, 1=Low, 2=Medium, 3=High *)
    HeatingElement : BOOL := FALSE; (* Direct heating control *)
    CoolingCompressor : BOOL := FALSE; (* Direct cooling control *)
    VentilationDamper : REAL := 0.0; (* Ventilation damper position 0.0-100.0% *)
    
    // Status outputs
    SystemStatus : HVAC_SystemStatus := STATUS_OFF;
    TemperatureAlarm : BOOL := FALSE;
    HumidityAlarm : BOOL := FALSE;
    SystemAlarms : HVAC_AlarmBits;
    
    // Monitoring outputs
    EnergyConsumption : REAL := 0.0; (* Estimated energy consumption in kWh *)
    MaintenanceRequired : BOOL := FALSE;
    
    // Diagnostic outputs
    FilteredTemperature : REAL := 0.0;
    FilteredHumidity : REAL := 0.0;
    TemperatureError : REAL := 0.0;
    HumidityError : REAL := 0.0;
END_VAR

VAR
    // Sanitized and filtered values
    AdjustedTemperature : REAL;
    AdjustedHumidity : REAL;
    TemperatureFiltered : REAL;
    HumidityFiltered : REAL;
    
    // Requirement flags with hysteresis
    NeedsHeating : BOOL;
    NeedsCooling : BOOL;
    NeedsVentilationHigh : BOOL; (* For high humidity *)
    NeedsVentilationLow : BOOL; (* For low humidity *)
    
    // Hysteresis states
    HeatingHysteresisState : BOOL := FALSE;
    CoolingHysteresisState : BOOL := FALSE;
    VentilationHighHysteresisState : BOOL := FALSE;
    VentilationLowHysteresisState : BOOL := FALSE;
    
    // Control logic
    ActiveMode : INT := 0;
    ActiveFanSpeed : INT := 0;
    
    // Timing and delays
    ModeChangeDelay : TON;
    SensorFilterTimer : TON;
    
    // Counters and accumulators
    OperatingHoursCounter : DINT := 0;
    EnergyAccumulator : REAL := 0.0;
    MaintenanceCounter : DINT := 0;
    
    // State management
    PreviousMode : INT := 0;
    SystemState : INT := 0;
    
    // Internal calculations
    TemperatureCalibrated : REAL;
    HumidityCalibrated : REAL;
    EffectiveDesiredTemperature : REAL;
    EffectiveDesiredHumidity : REAL;
    
    // Fan speed calculation
    TemperatureDeviation : REAL;
    HumidityDeviation : REAL;
    CalculatedFanSpeed : INT;
    
    // Constants
    MIN_TEMPERATURE : REAL := -50.0;
    MAX_TEMPERATURE : REAL := 100.0;
    MIN_HUMIDITY : REAL := 0.0;
    MAX_HUMIDITY : REAL := 100.0;
    MAINTENANCE_INTERVAL : DINT := 8760; (* Hours between maintenance *)
END_VAR

// Main execution logic
// 1. Input sanitization and calibration
TemperatureCalibrated := TemperatureSensor + TemperatureCalibrationOffset;
HumidityCalibrated := HumiditySensor + HumidityCalibrationOffset;

// Sanitize temperature
IF TemperatureCalibrated < MIN_TEMPERATURE THEN
    AdjustedTemperature := MIN_TEMPERATURE;
    SystemAlarms.TemperatureSensorFault := TRUE;
ELSIF TemperatureCalibrated > MAX_TEMPERATURE THEN
    AdjustedTemperature := MAX_TEMPERATURE;
    SystemAlarms.TemperatureSensorFault := TRUE;
ELSE
    AdjustedTemperature := TemperatureCalibrated;
    SystemAlarms.TemperatureSensorFault := FALSE;
END_IF;

// Sanitize humidity
IF HumidityCalibrated < MIN_HUMIDITY THEN
    AdjustedHumidity := MIN_HUMIDITY;
    SystemAlarms.HumiditySensorFault := TRUE;
ELSIF HumidityCalibrated > MAX_HUMIDITY THEN
    AdjustedHumidity := MAX_HUMIDITY;
    SystemAlarms.HumiditySensorFault := TRUE;
ELSE
    AdjustedHumidity := HumidityCalibrated;
    SystemAlarms.HumiditySensorFault := FALSE;
END_IF;

// 2. Sensor filtering (simple moving average)
SensorFilterTimer(IN := NOT SensorFilterTimer.Q, PT := SensorFilterTime);
IF SensorFilterTimer.Q THEN
    TemperatureFiltered := (TemperatureFiltered * 0.9) + (AdjustedTemperature * 0.1);
    HumidityFiltered := (HumidityFiltered * 0.9) + (AdjustedHumidity * 0.1);
    SensorFilterTimer(IN := FALSE);
END_IF;

// 3. Calculate effective setpoints
EffectiveDesiredTemperature := DesiredTemperature;
EffectiveDesiredHumidity := DesiredHumidity;

// 4. Calculate errors
TemperatureError := EffectiveDesiredTemperature - TemperatureFiltered;
HumidityError := EffectiveDesiredHumidity - HumidityFiltered;

// 5. Determine requirements with hysteresis
// Heating requirement with hysteresis
IF TemperatureFiltered < (EffectiveDesiredTemperature - TemperatureThreshold) THEN
    NeedsHeating := TRUE;
    HeatingHysteresisState := TRUE;
ELSIF TemperatureFiltered > (EffectiveDesiredTemperature - TemperatureThreshold + TemperatureHysteresis) AND HeatingHysteresisState THEN
    NeedsHeating := FALSE;
    HeatingHysteresisState := FALSE;
END_IF;

// Cooling requirement with hysteresis
IF TemperatureFiltered > (EffectiveDesiredTemperature + TemperatureThreshold) THEN
    NeedsCooling := TRUE;
    CoolingHysteresisState := TRUE;
ELSIF TemperatureFiltered < (EffectiveDesiredTemperature + TemperatureThreshold - TemperatureHysteresis) AND CoolingHysteresisState THEN
    NeedsCooling := FALSE;
    CoolingHysteresisState := FALSE;
END_IF;

// Ventilation for high humidity with hysteresis
IF HumidityFiltered > (EffectiveDesiredHumidity + HumidityThreshold) THEN
    NeedsVentilationHigh := TRUE;
    VentilationHighHysteresisState := TRUE;
ELSIF HumidityFiltered < (EffectiveDesiredHumidity + HumidityThreshold - HumidityHysteresis) AND VentilationHighHysteresisState THEN
    NeedsVentilationHigh := FALSE;
    VentilationHighHysteresisState := FALSE;
END_IF;

// Ventilation for low humidity with hysteresis
IF HumidityFiltered < (EffectiveDesiredHumidity - HumidityThreshold) THEN
    NeedsVentilationLow := TRUE;
    VentilationLowHysteresisState := TRUE;
ELSIF HumidityFiltered > (EffectiveDesiredHumidity - HumidityThreshold + HumidityHysteresis) AND VentilationLowHysteresisState THEN
    NeedsVentilationLow := FALSE;
    VentilationLowHysteresisState := FALSE;
END_IF;

// 6. Mode selection with prioritization and mutual exclusion
ModeChangeDelay(IN := (ActiveMode <> PreviousMode), PT := ModeChangeDelayTime);

IF EmergencyStop THEN
    ActiveMode := 0;
    ActiveFanSpeed := 0;
    SystemStatus := STATUS_OFF;
    
ELSIF ManualOverride THEN
    ActiveMode := LIMIT(0, ModeOverride, 3);
    ActiveFanSpeed := LIMIT(0, FanSpeedOverride, 3);
    SystemStatus := HVAC_SystemStatus(ActiveMode + 1); // Map to status enum
    
ELSE
    // Normal automatic control with prioritization
    IF NeedsHeating AND NOT NeedsCooling THEN
        // Heating has priority
        IF ModeChangeDelay.Q OR ActiveMode = 2 THEN
            ActiveMode := 2; // Heating
            SystemStatus := STATUS_HEATING;
        END_IF;
        
    ELSIF NeedsCooling AND NOT NeedsHeating THEN
        // Cooling has priority (mutually exclusive with heating)
        IF ModeChangeDelay.Q OR ActiveMode = 1 THEN
            ActiveMode := 1; // Cooling
            SystemStatus := STATUS_COOLING;
        END_IF;
        
    ELSIF (NeedsVentilationHigh OR NeedsVentilationLow) AND NOT (NeedsHeating OR NeedsCooling) THEN
        // Ventilation only when no temperature control needed
        IF ModeChangeDelay.Q OR ActiveMode = 3 THEN
            ActiveMode := 3; // Ventilation
            SystemStatus := STATUS_VENTILATING;
        END_IF;
        
    ELSE
        // No requirements met
        ActiveMode := 0; // Off
        SystemStatus := STATUS_STANDBY;
    END_IF;
    
    // Calculate appropriate fan speed based on deviation
    TemperatureDeviation := ABS(TemperatureError);
    HumidityDeviation := ABS(HumidityError);
    
    CASE ActiveMode OF
        1, 2: // Heating or Cooling
            IF TemperatureDeviation > (TemperatureThreshold * 2) THEN
                CalculatedFanSpeed := 3; // High
            ELSIF TemperatureDeviation > TemperatureThreshold THEN
                CalculatedFanSpeed := 2; // Medium
            ELSE
                CalculatedFanSpeed := 1; // Low
            END_IF;
            
        3: // Ventilation
            IF HumidityDeviation > (HumidityThreshold * 2) THEN
                CalculatedFanSpeed := 3; // High
            ELSIF HumidityDeviation > HumidityThreshold THEN
                CalculatedFanSpeed := 2; // Medium
            ELSE
                CalculatedFanSpeed := 1; // Low
            END_IF;
            
        ELSE: // Off
            CalculatedFanSpeed := 0;
    END_CASE;
    
    ActiveFanSpeed := CalculatedFanSpeed;
END_IF;

// 7. Set direct control outputs with safety interlocks
HeatingElement := (ActiveMode = 2) AND NOT EmergencyStop AND NOT SystemAlarms.HeatingFault;
CoolingCompressor := (ActiveMode = 1) AND NOT EmergencyStop AND NOT SystemAlarms.CoolingFault;

// Ventilation damper position based on humidity error
IF ActiveMode = 3 THEN
    VentilationDamper := LIMIT(0.0, ABS(HumidityError) * 2.0, 100.0);
ELSE
    VentilationDamper := 0.0;
END_IF;

// 8. Update output variables
HVACMode := ActiveMode;
HVACFanSpeed := ActiveFanSpeed;

// 9. Update diagnostic outputs
FilteredTemperature := TemperatureFiltered;
FilteredHumidity := HumidityFiltered;

// 10. Alarm generation
TemperatureAlarm := SystemAlarms.TemperatureSensorFault OR (ABS(TemperatureError) > (TemperatureThreshold * 3));
HumidityAlarm := SystemAlarms.HumiditySensorFault OR (ABS(HumidityError) > (HumidityThreshold * 3));

// 11. Energy and maintenance tracking
IF ActiveMode <> 0 THEN
    OperatingHoursCounter := OperatingHoursCounter + 1;
    
    // Simple energy estimation
    CASE ActiveMode OF
        1: EnergyAccumulator := EnergyAccumulator + 3.5; // Cooling energy
        2: EnergyAccumulator := EnergyAccumulator + 4.0; // Heating energy
        3: EnergyAccumulator := EnergyAccumulator + 0.5; // Ventilation energy
    END_CASE;
END_IF;

EnergyConsumption := EnergyAccumulator;

// Maintenance tracking
MaintenanceCounter := OperatingHoursCounter;
MaintenanceRequired := (MaintenanceCounter >= MAINTENANCE_INTERVAL);
SystemAlarms.MaintenanceRequired := MaintenanceRequired;

// 12. Update previous mode for change detection
IF ModeChangeDelay.Q THEN
    PreviousMode := ActiveMode;
END_IF;

// 13. Fault status handling
IF EmergencyStop THEN
    SystemStatus := STATUS_OFF;
ELSIF SystemAlarms.TemperatureSensorFault OR SystemAlarms.HumiditySensorFault OR 
      SystemAlarms.HeatingFault OR SystemAlarms.CoolingFault OR SystemAlarms.VentilationFault THEN
    SystemStatus := STATUS_FAULT;
END_IF;
END_FUNCTION_BLOCK;