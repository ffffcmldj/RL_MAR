ructured-text
START_ST
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
    NeedsVentilation : BOOL := FALSE; (* Flag for ventilation requirement *)
    NeedsHeating : BOOL := FALSE; (* Flag for heating requirement *)
    NeedsCooling : BOOL := FALSE; (* Flag for cooling requirement *)
    state : INT; (* The state variable *)
    prevState : INT; (* The previous state variable *)
END_VAR

(* State Definitions *)
(* STATE 0: INITIALIZE *)
IF state = 0 THEN
    HVACMode := 0;
    HVACFanSpeed := 0;
    state := 1; (* Transition to STATE 1 *)
END_IF

(* STATE 1: SANITIZE INPUTS *)
IF state = 1 THEN
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

    state := 2; (* Transition to STATE 2 *)
END_IF

(* STATE 2: DETERMINE REQUIREMENTS *)
IF state = 2 THEN
    IF AdjustedHumidity < DesiredHumidity - HumidityThreshold THEN
        NeedsVentilation := TRUE;
    ELSE
        NeedsVentilation := FALSE;
    END_IF;

    IF AdjustedTemperature < DesiredTemperature - TemperatureThreshold THEN
        NeedsHeating := TRUE;
    ELSE
        NeedsHeating := FALSE;
    END_IF;

    IF AdjustedTemperature > DesiredTemperature + TemperatureThreshold THEN
        NeedsCooling := TRUE;
    ELSE
        NeedsCooling := FALSE;
    END_IF;

    state := 3; (* Transition to STATE 3 *)
END_IF

(* STATE 3: CONTROL HVAC *)
IF state = 3 THEN
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

    IF HVACMode = 0 THEN
        state := 0; (* Transition back to STATE 0 for the next cycle *)
    END_IF;
END_IF

END_FUNCTION_BLOCK
END_ST