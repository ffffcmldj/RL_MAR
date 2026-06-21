FUNCTION_BLOCK BakeryOvenControl
VAR_INPUT
    TemperatureSensor : REAL;           (* Current oven temperature reading *)
    HumiditySensor : REAL;              (* Current oven humidity reading *)
    StartOven : BOOL;                   (* Command to start the oven *)
    TemperatureSetpoint : REAL;         (* Desired temperature setpoint *)
    HumiditySetpoint : REAL;            (* Desired humidity setpoint *)
    BakingTimeSetpoint : TIME;          (* Total baking time *)
    TemperatureThreshold : REAL := 2.0; (* Temperature control deadband *)
    HumidityThreshold : REAL := 5.0;    (* Humidity control deadband *)
END_VAR

VAR_OUTPUT
    HeatingElement : BOOL;              (* Control signal for heating element *)
    CoolingElement : BOOL;              (* Control signal for cooling element *)
    HumidityControl : BOOL;             (* Control signal for humidification *)
    DehumidityControl : BOOL;           (* Control signal for dehumidification *)
    OvenActive : BOOL;                  (* Oven status: TRUE when baking *)
    RemainingTime : TIME;               (* Remaining baking time *)
END_VAR

VAR
    BakingTimer : TON;                  (* Timer for baking duration *)
    OneSecondPulse : TON;               (* Timer for 1-second pulse generation *)
    PulseSignal : BOOL;                 (* Internal 1-second pulse *)
    InternalRemainingTime : TIME;       (* Internal remaining time counter *)
END_VAR

(* Initialize timers *)
OneSecondPulse(IN := NOT OneSecondPulse.Q, PT := T#1S);
PulseSignal := OneSecondPulse.Q;

(* Oven control logic *)
IF StartOven AND NOT OvenActive THEN
    (* Start baking cycle *)
    OvenActive := TRUE;
    InternalRemainingTime := BakingTimeSetpoint;
    BakingTimer(IN := TRUE, PT := BakingTimeSetpoint);
ELSIF NOT StartOven THEN
    (* Manual stop or initialization *)
    OvenActive := FALSE;
    BakingTimer(IN := FALSE, PT := T#0S);
END_IF

(* Decrement remaining time when oven is active *)
IF OvenActive AND PulseSignal THEN
    IF InternalRemainingTime >= T#1S THEN
        InternalRemainingTime := InternalRemainingTime - T#1S;
    ELSE
        InternalRemainingTime := T#0S;
    END_IF;
END_IF;

(* Stop oven when timer expires *)
IF BakingTimer.Q THEN
    OvenActive := FALSE;
END_IF;

(* Temperature control - only active when oven is on *)
IF OvenActive THEN
    HeatingElement := TemperatureSensor < (TemperatureSetpoint - TemperatureThreshold);
    CoolingElement := TemperatureSensor > (TemperatureSetpoint + TemperatureThreshold);
ELSE
    HeatingElement := FALSE;
    CoolingElement := FALSE;
END_IF;

(* Humidity control - only active when oven is on *)
IF OvenActive THEN
    HumidityControl := HumiditySensor < (HumiditySetpoint - HumidityThreshold);
    DehumidityControl := HumiditySensor > (HumiditySetpoint + HumidityThreshold);
ELSE
    HumidityControl := FALSE;
    DehumidityControl := FALSE;
END_IF;

(* Output remaining time *)
RemainingTime := InternalRemainingTime;

(* Ensure all outputs are off when oven is not active *)
IF NOT OvenActive THEN
    HeatingElement := FALSE;
    CoolingElement := FALSE;
    HumidityControl := FALSE;
    DehumidityControl := FALSE;
    InternalRemainingTime := T#0S;
END_IF;
END_FUNCTION_BLOCK