plaintext
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
    state : INT := 0; (* Current state of the FSM *)
END_VAR

(* Main logic *)
CASE state OF
    (* STATE 0: INITIALIZE *)
    0:
        NeedsVentilation := FALSE;
        NeedsHeating := FALSE;
        NeedsCooling := FALSE;
        HVACMode := 0; (* Off *)
        HVACFanSpeed := 0; (* Off *)
        state := 1; (* Transition to STATE 1 *)

    (* STATE 1: SANITIZE INPUTS *)
    1:
        (* Sanitize temperature input *)
        IF TemperatureSensor < -50.0 THEN
            AdjustedTemperature := -50.0;
        ELSIF TemperatureSensor > 100.0 THEN
            AdjustedTemperature := 100.0;
        ELSE
            AdjustedTemperature := TemperatureSensor;
        END_IF;

        (* Sanitize humidity input *)
        IF HumiditySensor < 0.0 THEN
            AdjustedHumidity := 0.0;
        ELSIF HumiditySensor > 100.0 THEN
            AdjustedHumidity := 100.0;
        ELSE
            AdjustedHumidity := HumiditySensor;
        END_IF;

        state := 2; (* Transition to STATE 2 *)

    (* STATE 2: DETERMINE REQUIREMENTS *)
    2:
        (* Determine ventilation requirement *)
        IF AdjustedHumidity < (DesiredHumidity - HumidityThreshold) THEN
            NeedsVentilation := TRUE;
        ELSE
            NeedsVentilation := FALSE;
        END_IF;

        (* Determine heating requirement *)
        IF AdjustedTemperature < (DesiredTemperature - TemperatureThreshold) THEN
            NeedsHeating := TRUE;
        ELSE
            NeedsHeating := FALSE;
        END_IF;

        (* Determine cooling requirement *)
        IF AdjustedTemperature > (DesiredTemperature + TemperatureThreshold) THEN
            NeedsCooling := TRUE;
        ELSE
            NeedsCooling := FALSE;
        END_IF;

        state := 3; (* Transition to STATE 3 *)

    (* STATE 3: CONTROL HVAC MODE AND FAN SPEED *)
    3:
        (* Prioritize heating, then cooling, then ventilation *)
        IF NeedsHeating THEN
            HVACMode := 2; (* Heating *)
            HVACFanSpeed := 3; (* High *)
        ELSIF NeedsCooling THEN
            HVACMode := 1; (* Cooling *)
            HVACFanSpeed := 3; (* High *)
        ELSIF NeedsVentilation THEN
            HVACMode := 3; (* Ventilation *)
            HVACFanSpeed := 3; (* High *)
        ELSE
            HVACMode := 0; (* Off *)
            HVACFanSpeed := 0; (* Off *)
        END_IF;

        state := 1; (* Transition back to STATE 1 for the next cycle *)
END_CASE;
END_FUNCTION_BLOCK
END_ST