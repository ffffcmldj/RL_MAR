FUNCTION_BLOCK SmartHVACSystem
VAR_INPUT
    TemperatureSensor : REAL; (* Temperature sensor reading *)
    HumiditySensor : REAL; (* Humidity sensor reading *)
END_VAR
VAR_OUTPUT
    HVACMode : INT := 0; (* HVAC operating mode: 0=Off, 1=Cooling, 2=Heating, 3=Ventilation *)
    HVACFanSpeed : INT := 0; (* Fan speed: 0=Off, 1=Low, 2=Medium, 3=High *)
END_VAR
VAR
    DesiredTemperature : REAL := 24.0; (* Desired temperature setting *)
    DesiredHumidity : REAL := 50.0; (* Desired humidity setting *)
    TemperatureThreshold : REAL := 1.0; (* Temperature tolerance threshold *)
    HumidityThreshold : REAL := 5.0; (* Humidity tolerance threshold *)
    AdjustedHumidity : REAL; (* Sanitized humidity input *)
    AdjustedTemperature : REAL; (* Sanitized temperature input *)
    NeedsVentilation : BOOL; (* Flag for ventilation requirement *)
    NeedsHeating : BOOL; (* Flag for heating requirement *)
    NeedsCooling : BOOL; (* Flag for cooling requirement *)
END_VAR

(* Input Sanitization *)
IF HumiditySensor < 0.0 THEN
    AdjustedHumidity := 0.0;
ELSIF HumiditySensor > 100.0 THEN
    AdjustedHumidity := 100.0;
ELSE
    AdjustedHumidity := HumiditySensor;
END_IF;

IF TemperatureSensor < -50.0 THEN
    AdjustedTemperature := -50.0;
ELSIF TemperatureSensor > 100.0 THEN
    AdjustedTemperature := 100.0;
ELSE
    AdjustedTemperature := TemperatureSensor;
END_IF;

(* Determine System Requirements *)
NeedsVentilation := AdjustedHumidity < (DesiredHumidity - HumidityThreshold);
NeedsHeating := AdjustedTemperature < (DesiredTemperature - TemperatureThreshold);
NeedsCooling := AdjustedTemperature > (DesiredTemperature + TemperatureThreshold);

(* Control Logic with Priority: Heating > Cooling > Ventilation *)
IF NeedsHeating THEN
    HVACMode := 2;
    HVACFanSpeed := 3;
ELSIF NeedsCooling THEN
    HVACMode := 1;
    HVACFanSpeed := 3;
ELSIF NeedsVentilation THEN
    HVACMode := 3;
    HVACFanSpeed := 3;
ELSE
    HVACMode := 0;
    HVACFanSpeed := 0;
END_IF;

END_FUNCTION_BLOCK