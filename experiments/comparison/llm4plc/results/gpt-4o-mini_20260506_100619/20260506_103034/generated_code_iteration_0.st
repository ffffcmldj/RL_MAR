ructured-text
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
    state : INT; (* The current state variable (0 to 3) *)
    prevState : INT; (* The previous state variable *)
    OvenTemperature : REAL := 0.0; (* Current oven temperature setpoint *)
    OvenHumidity : REAL := 0.0; (* Current oven humidity setpoint *)
    BakingTime : TIME := T#0s; (* Remaining baking time *)
    HeatingThreshold : REAL := 2.0; (* Temperature control threshold *)
    HumidityThreshold : REAL := 5.0; (* Humidity control threshold *)
END_VAR

(* State Definitions *)
CONST
    STATE_OFF : INT := 0;
    STATE_ON : INT := 1;
    STATE_BAKING : INT := 2;
    STATE_COMPLETE : INT := 3;
END_CONST

(* State Logic Implementation *)
CASE state OF
    STATE_OFF:
        (* Set all control outputs to OFF *)
        HeatingElement := FALSE;
        CoolingElement := FALSE;
        HumidityControl := FALSE;
        DehumidityControl := FALSE;

        (* Transition to STATE_ON if OvenStatus is TRUE *)
        IF OvenStatus THEN
            state := STATE_ON;
        END_IF;

    STATE_ON:
        (* Regulating temperature and humidity *)
        IF TemperatureSensor < (OvenTemperature - HeatingThreshold) THEN
            HeatingElement := TRUE;
        ELSE
            HeatingElement := FALSE;
        END_IF;

        IF TemperatureSensor > (OvenTemperature + HeatingThreshold) THEN
            CoolingElement := TRUE;
        ELSE
            CoolingElement := FALSE;
        END_IF;

        IF HumiditySensor < (OvenHumidity - HumidityThreshold) THEN
            HumidityControl := TRUE;
        ELSE
            HumidityControl := FALSE;
        END_IF;

        IF HumiditySensor > (OvenHumidity + HumidityThreshold) THEN
            DehumidityControl := TRUE;
        ELSE
            DehumidityControl := FALSE;
        END_IF;

        (* Transition to STATE_BAKING if BakingTime > T#0s *)
        IF (BakingTime > T#0s) THEN
            state := STATE_BAKING;
        END_IF;

    STATE_BAKING:
        (* Decrement BakingTime by 1 second each cycle *)
        BakingTime := BakingTime - T#1s;

        (* Use the same temperature and humidity control logic as in STATE_ON *)
        IF TemperatureSensor < (OvenTemperature - HeatingThreshold) THEN
            HeatingElement := TRUE;
        ELSE
            HeatingElement := FALSE;
        END_IF;

        IF TemperatureSensor > (OvenTemperature + HeatingThreshold) THEN
            CoolingElement := TRUE;
        ELSE
            CoolingElement := FALSE;
        END_IF;

        IF HumiditySensor < (OvenHumidity - HumidityThreshold) THEN
            HumidityControl := TRUE;
        ELSE
            HumidityControl := FALSE;
        END_IF;

        IF HumiditySensor > (OvenHumidity + HumidityThreshold) THEN
            DehumidityControl := TRUE;
        ELSE
            DehumidityControl := FALSE;
        END_IF;

        (* Transition to STATE_COMPLETE if BakingTime = T#0s *)
        IF (BakingTime = T#0s) THEN
            state := STATE_COMPLETE;
        END_IF;

    STATE_COMPLETE:
        (* Set all control outputs to OFF *)
        HeatingElement := FALSE;
        CoolingElement := FALSE;
        HumidityControl := FALSE;
        DehumidityControl := FALSE;

        (* Transition to STATE_OFF if OvenStatus is FALSE *)
        IF NOT OvenStatus THEN
            state := STATE_OFF;
        END_IF;

END_CASE;

END_FUNCTION_BLOCK