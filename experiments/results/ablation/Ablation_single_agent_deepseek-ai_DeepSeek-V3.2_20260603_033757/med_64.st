FUNCTION_BLOCK BakeryOvenControl
VAR_INPUT
    TemperatureSensor : REAL;        (* Current measured oven temperature in °C *)
    HumiditySensor : REAL;           (* Current measured oven humidity in %RH *)
    StartBaking : BOOL;              (* Command to start baking cycle *)
    StopBaking : BOOL;               (* Command to stop baking cycle immediately *)
END_VAR

VAR_OUTPUT
    HeatingElement : BOOL;           (* Control signal for heating element *)
    CoolingElement : BOOL;           (* Control signal for cooling element *)
    HumidityControl : BOOL;          (* Control signal for humidification system *)
    DehumidityControl : BOOL;        (* Control signal for dehumidification system *)
    BakingComplete : BOOL;           (* Signal indicating baking cycle is complete *)
    RemainingTime : TIME;            (* Remaining baking time display *)
END_VAR

VAR
    (* Setpoints - initialized when oven is off *)
    TemperatureSetpoint : REAL := 180.0;     (* Desired baking temperature in °C *)
    HumiditySetpoint : REAL := 65.0;         (* Desired baking humidity in %RH *)
    BakingTimeSetpoint : TIME := T#30M;      (* Total baking time *)
    
    (* Control thresholds - configurable for different baking requirements *)
    TemperatureThreshold : REAL := 2.0;      (* Temperature deadband threshold *)
    HumidityThreshold : REAL := 5.0;         (* Humidity deadband threshold *)
    
    (* Internal state variables *)
    OvenActive : BOOL := FALSE;              (* TRUE when baking cycle is active *)
    TimerValue : TIME := T#0S;               (* Current timer value *)
    TimerEnable : BOOL := FALSE;             (* Timer enable flag *)
    
    (* Edge detection for start/stop commands *)
    StartRisingEdge : R_TRIG;
    StopRisingEdge : R_TRIG;
END_VAR

(* Edge detection for start/stop commands *)
StartRisingEdge(CLK := StartBaking);
StopRisingEdge(CLK := StopBaking);

(* Main control logic *)
IF NOT OvenActive THEN
    (* Oven is inactive - deactivate all outputs *)
    HeatingElement := FALSE;
    CoolingElement := FALSE;
    HumidityControl := FALSE;
    DehumidityControl := FALSE;
    BakingComplete := FALSE;
    TimerValue := T#0S;
    TimerEnable := FALSE;
    
    (* Initialize setpoints when oven is off (can be modified externally) *)
    TemperatureSetpoint := 180.0;    (* Default temperature setpoint *)
    HumiditySetpoint := 65.0;        (* Default humidity setpoint *)
    BakingTimeSetpoint := T#30M;     (* Default baking time *)
    
    (* Start baking cycle on rising edge of StartBaking *)
    IF StartRisingEdge.Q THEN
        OvenActive := TRUE;
        TimerValue := BakingTimeSetpoint;
        TimerEnable := TRUE;
        BakingComplete := FALSE;
    END_IF;
    
ELSE
    (* Oven is active - implement control logic *)
    
    (* Stop baking immediately if stop command received *)
    IF StopRisingEdge.Q THEN
        OvenActive := FALSE;
        HeatingElement := FALSE;
        CoolingElement := FALSE;
        HumidityControl := FALSE;
        DehumidityControl := FALSE;
        BakingComplete := TRUE;
        TimerEnable := FALSE;
    ELSE
        (* Temperature Control Logic *)
        IF TemperatureSensor < (TemperatureSetpoint - TemperatureThreshold) THEN
            (* Temperature below lower threshold - activate heating *)
            HeatingElement := TRUE;
            CoolingElement := FALSE;
        ELSIF TemperatureSensor > (TemperatureSetpoint + TemperatureThreshold) THEN
            (* Temperature above upper threshold - activate cooling *)
            HeatingElement := FALSE;
            CoolingElement := TRUE;
        ELSE
            (* Temperature within acceptable range - turn off both systems *)
            HeatingElement := FALSE;
            CoolingElement := FALSE;
        END_IF;
        
        (* Humidity Control Logic *)
        IF HumiditySensor < (HumiditySetpoint - HumidityThreshold) THEN
            (* Humidity below lower threshold - activate humidification *)
            HumidityControl := TRUE;
            DehumidityControl := FALSE;
        ELSIF HumiditySensor > (HumiditySetpoint + HumidityThreshold) THEN
            (* Humidity above upper threshold - activate dehumidification *)
            HumidityControl := FALSE;
            DehumidityControl := TRUE;
        ELSE
            (* Humidity within acceptable range - turn off both systems *)
            HumidityControl := FALSE;
            DehumidityControl := FALSE;
        END_IF;
        
        (* Baking Timer Logic *)
        IF TimerEnable AND (TimerValue > T#0S) THEN
            (* Decrement timer at one-second intervals *)
            TimerValue := TimerValue - T#1S;
        END_IF;
        
        (* Check if baking is complete *)
        IF TimerValue <= T#0S THEN
            (* Baking time elapsed - turn off all systems *)
            HeatingElement := FALSE;
            CoolingElement := FALSE;
            HumidityControl := FALSE;
            DehumidityControl := FALSE;
            BakingComplete := TRUE;
            TimerEnable := FALSE;
            OvenActive := FALSE;
        ELSE
            BakingComplete := FALSE;
        END_IF;
    END_IF;
END_IF;

(* Output remaining time for display *)
RemainingTime := TimerValue;

END_FUNCTION_BLOCK