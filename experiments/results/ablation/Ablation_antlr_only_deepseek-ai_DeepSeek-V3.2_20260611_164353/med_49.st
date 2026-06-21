(*
    FUNCTION_BLOCK: SmartHVACSystem
    Description: Controls a smart HVAC system by monitoring temperature and humidity.
                 Sanitizes sensor inputs, determines heating/cooling/ventilation needs
                 with priority for heating/cooling, and controls operating mode and fan speed.
    Author: Senior PLC Commissioning Engineer
    Standard: IEC 61131-3
    Version: 1.0
*)

FUNCTION_BLOCK SmartHVACSystem
VAR_INPUT
    (* Primary sensor inputs *)
    TemperatureSensor : REAL;    (* Raw temperature sensor reading (°C) *)
    HumiditySensor    : REAL;    (* Raw humidity sensor reading (%) *)
END_VAR

VAR_OUTPUT
    (* Control outputs *)
    HVACMode      : INT := 0;    (* 0=Off, 1=Cooling, 2=Heating, 3=Ventilation *)
    HVACFanSpeed  : INT := 0;    (* 0=Off, 1=Low, 2=Medium, 3=High *)
END_VAR

VAR
    (* User-configurable setpoints and thresholds *)
    DesiredTemperature : REAL := 24.0;    (* Default desired temperature (°C) *)
    DesiredHumidity    : REAL := 50.0;    (* Default desired humidity (%) *)
    TemperatureThreshold : REAL := 1.0;   (* Temperature deadband (±°C) *)
    HumidityThreshold    : REAL := 5.0;   (* Humidity deadband (±%) *)

    (* Sanitized sensor values *)
    AdjustedTemperature : REAL;    (* Clamped temperature value *)
    AdjustedHumidity    : REAL;    (* Clamped humidity value *)

    (* Requirement flags *)
    NeedsHeating     : BOOL;    (* TRUE when heating required *)
    NeedsCooling     : BOOL;    (* TRUE when cooling required *)
    NeedsVentilation : BOOL;    (* TRUE when ventilation required *)
END_VAR

(*
    Main execution logic
    Implements: Input sanitization, requirement determination,
                prioritized control, and output assignment.
*)

(* 1. INPUT SANITIZATION *)
(* Temperature: clamp between -50.0°C and 100.0°C *)
IF TemperatureSensor < -50.0 THEN
    AdjustedTemperature := -50.0;
ELSIF TemperatureSensor > 100.0 THEN
    AdjustedTemperature := 100.0;
ELSE
    AdjustedTemperature := TemperatureSensor;
END_IF;

(* Humidity: clamp between 0.0% and 100.0% *)
IF HumiditySensor < 0.0 THEN
    AdjustedHumidity := 0.0;
ELSIF HumiditySensor > 100.0 THEN
    AdjustedHumidity := 100.0;
ELSE
    AdjustedHumidity := HumiditySensor;
END_IF;

(* 2. DETERMINE SYSTEM REQUIREMENTS *)
(* Heating requirement: temperature below lower threshold *)
NeedsHeating := AdjustedTemperature < (DesiredTemperature - TemperatureThreshold);

(* Cooling requirement: temperature above upper threshold *)
NeedsCooling := AdjustedTemperature > (DesiredTemperature + TemperatureThreshold);

(* Ventilation requirement: humidity below lower threshold *)
NeedsVentilation := AdjustedHumidity < (DesiredHumidity - HumidityThreshold);

(* 3. PRIORITIZED CONTROL LOGIC *)
(* Priority: Heating > Cooling > Ventilation > Off *)
IF NeedsHeating THEN
    HVACMode := 2;        (* Heating mode *)
    HVACFanSpeed := 3;    (* High fan speed *)
ELSIF NeedsCooling THEN
    HVACMode := 1;        (* Cooling mode *)
    HVACFanSpeed := 3;    (* High fan speed *)
ELSIF NeedsVentilation THEN
    HVACMode := 3;        (* Ventilation mode *)
    HVACFanSpeed := 3;    (* High fan speed *)
ELSE
    HVACMode := 0;        (* System off *)
    HVACFanSpeed := 0;    (* Fan off *)
END_IF;

END_FUNCTION_BLOCK;