FUNCTION_BLOCK BakeryOvenControl
VAR_INPUT
    TemperatureSensor : REAL;           (* Current oven temperature measurement *)
    HumiditySensor : REAL;              (* Current oven humidity measurement *)
    TemperatureSetpoint : REAL := 180.0; (* Desired temperature setpoint *)
    HumiditySetpoint : REAL := 60.0;    (* Desired humidity setpoint *)
    BakingTimeSetpoint : TIME := T#30m; (* Total baking duration *)
    OvenEnable : BOOL;                  (* Master enable signal for oven operation *)
    TemperatureThreshold : REAL := 2.0; (* Temperature control deadband *)
    HumidityThreshold : REAL := 5.0;    (* Humidity control deadband *)
END_VAR

VAR_OUTPUT
    HeatingElement : BOOL;              (* Control output for heating element *)
    CoolingElement : BOOL;              (* Control output for cooling element *)
    HumidityControl : BOOL;             (* Control output for humidification system *)
    DehumidityControl : BOOL;           (* Control output for dehumidification system *)
    BakingComplete : BOOL;              (* Flag indicating baking cycle completion *)
    RemainingTimeDisplay : TIME;        (* Remaining baking time for display *)
END_VAR

VAR
    RemainingTime : TIME;               (* Internal remaining time counter *)
    OneSecTimer : TON;                  (* Timer for one-second intervals *)
    OvenActive : BOOL;                  (* Internal oven active state *)
    StartBaking : BOOL;                 (* Edge detection for baking start *)
    TemperatureLowLimit : REAL;         (* Calculated temperature lower limit *)
    TemperatureHighLimit : REAL;        (* Calculated temperature upper limit *)
    HumidityLowLimit : REAL;            (* Calculated humidity lower limit *)
    HumidityHighLimit : REAL;           (* Calculated humidity upper limit *)
    PrevOvenEnable : BOOL;              (* Previous state for edge detection *)
END_VAR

(* Calculate control limits based on setpoints and thresholds *)
TemperatureLowLimit := TemperatureSetpoint - TemperatureThreshold;
TemperatureHighLimit := TemperatureSetpoint + TemperatureThreshold;
HumidityLowLimit := HumiditySetpoint - HumidityThreshold;
HumidityHighLimit := HumiditySetpoint + HumidityThreshold;

(* Edge detection for oven enable signal *)
StartBaking := OvenEnable AND NOT PrevOvenEnable;
PrevOvenEnable := OvenEnable;

(* Oven state management *)
IF StartBaking THEN
    (* Initialize baking cycle when oven is first enabled *)
    RemainingTime := BakingTimeSetpoint;
    OvenActive := TRUE;
    BakingComplete := FALSE;
ELSIF NOT OvenEnable THEN
    (* Force oven inactive when enable signal is removed *)
    OvenActive := FALSE;
    BakingComplete := FALSE;
END_IF;

(* Timer logic for one-second decrement *)
OneSecTimer(IN := OvenActive, PT := T#1s);

IF OneSecTimer.Q THEN
    (* Decrement remaining time each second *)
    IF RemainingTime > T#0s THEN
        RemainingTime := RemainingTime - T#1s;
    END_IF;
    
    (* Check for baking completion *)
    IF RemainingTime <= T#0s THEN
        OvenActive := FALSE;
        BakingComplete := TRUE;
    END_IF;
END_IF;

(* Update display output *)
RemainingTimeDisplay := RemainingTime;

(* Temperature control logic - evaluated every scan *)
IF OvenActive AND (RemainingTime > T#0s) THEN
    (* Heating control *)
    IF TemperatureSensor < TemperatureLowLimit THEN
        HeatingElement := TRUE;
        CoolingElement := FALSE;
    (* Cooling control *)
    ELSIF TemperatureSensor > TemperatureHighLimit THEN
        HeatingElement := FALSE;
        CoolingElement := TRUE;
    (* Within acceptable range *)
    ELSE
        HeatingElement := FALSE;
        CoolingElement := FALSE;
    END_IF;
    
    (* Humidity control *)
    IF HumiditySensor < HumidityLowLimit THEN
        HumidityControl := TRUE;
        DehumidityControl := FALSE;
    (* Dehumidification control *)
    ELSIF HumiditySensor > HumidityHighLimit THEN
        HumidityControl := FALSE;
        DehumidityControl := TRUE;
    (* Within acceptable range *)
    ELSE
        HumidityControl := FALSE;
        DehumidityControl := FALSE;
    END_IF;
ELSE
    (* Oven inactive or baking complete - force all outputs OFF *)
    HeatingElement := FALSE;
    CoolingElement := FALSE;
    HumidityControl := FALSE;
    DehumidityControl := FALSE;
END_IF;
END_FUNCTION_BLOCK