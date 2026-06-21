FUNCTION_BLOCK BakeryOvenControl
VAR_INPUT
    TemperatureSensor : REAL; (* Sensor input for oven temperature *)
    HumiditySensor : REAL; (* Sensor input for oven humidity *)
END_VAR

VAR_OUTPUT
    HeatingElement : BOOL; (* Control signal for heating element *)
    CoolingElement : BOOL; (* Control signal for cooling element *)
    HumidityControl : BOOL; (* Control signal for humidity system *)
    DehumidityControl : BOOL; (* Control signal for dehumidification *)
END_VAR

VAR
    OvenTemperature : REAL := 180.0; (* Current oven temperature setpoint *)
    OvenHumidity : REAL := 60.0; (* Current oven humidity setpoint *)
    BakingTime : TIME := T#30M0S; (* Baking time setpoint *)
    OvenStatus : BOOL := FALSE; (* Oven status: TRUE=On, FALSE=Off *)
    HeatingThreshold : REAL := 2.0; (* Temperature control threshold *)
    HumidityThreshold : REAL := 5.0; (* Humidity control threshold *)
    TimerInstance : TON; (* Timer instance for 1-second decrement *)
    TimerPulse : BOOL := FALSE; (* Pulse for timer decrement *)
    InternalBakingTime : TIME := T#0S; (* Internal copy of baking time *)
END_VAR

(* Main logic body begins here *)

(* Timer for 1-second pulse generation *)
TimerInstance(IN := OvenStatus AND (InternalBakingTime > T#0S), PT := T#1S);
TimerPulse := TimerInstance.Q;

(* Decrement baking timer when oven is on and timer pulse is active *)
IF OvenStatus AND TimerPulse THEN
    IF InternalBakingTime > T#0S THEN
        InternalBakingTime := InternalBakingTime - T#1S;
    END_IF;
END_IF;

(* Reset internal timer when oven turns off *)
IF NOT OvenStatus THEN
    InternalBakingTime := BakingTime;
END_IF;

(* Main control logic - only active when oven is on and timer not expired *)
IF OvenStatus AND (InternalBakingTime > T#0S) THEN
    (* Temperature control logic *)
    IF TemperatureSensor < (OvenTemperature - HeatingThreshold) THEN
        HeatingElement := TRUE;
        CoolingElement := FALSE;
    ELSIF TemperatureSensor > (OvenTemperature + HeatingThreshold) THEN
        HeatingElement := FALSE;
        CoolingElement := TRUE;
    ELSE
        HeatingElement := FALSE;
        CoolingElement := FALSE;
    END_IF;
    
    (* Humidity control logic *)
    IF HumiditySensor < (OvenHumidity - HumidityThreshold) THEN
        HumidityControl := TRUE;
        DehumidityControl := FALSE;
    ELSIF HumiditySensor > (OvenHumidity + HumidityThreshold) THEN
        HumidityControl := FALSE;
        DehumidityControl := TRUE;
    ELSE
        HumidityControl := FALSE;
        DehumidityControl := FALSE;
    END_IF;
    
(* Oven off or timer expired - turn off all outputs *)
ELSE
    HeatingElement := FALSE;
    CoolingElement := FALSE;
    HumidityControl := FALSE;
    DehumidityControl := FALSE;
    
    (* Auto-shutdown when timer expires *)
    IF (InternalBakingTime <= T#0S) AND OvenStatus THEN
        OvenStatus := FALSE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK;