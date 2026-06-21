plaintext
START_ST
FUNCTION_BLOCK BakeryOvenControl
VAR_INPUT
    TemperatureSensor : REAL; (* Sensor input for oven temperature *)
    HumiditySensor : REAL; (* Sensor input for oven humidity *)
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL; (* Control signal for heating element *)
    CoolingElement : BOOL; (* Control signal for cooling element *)
    HumidityControl : BOOL; (* Control signal for humidity system *)
    DehumidityControl : BOOL; (* Control signal for dehumidification system *)
END_VAR
VAR
    State : INT := 0; (* Current state of the finite state machine *)
    OvenTemperature : REAL := 0.0; (* Desired oven temperature setpoint *)
    OvenHumidity : REAL := 0.0; (* Desired oven humidity setpoint *)
    BakingTime : TIME := T#0s; (* Remaining baking time *)
    OvenStatus : BOOL := FALSE; (* TRUE = Oven is on, FALSE = Oven is off *)
    HeatingThreshold : REAL := 2.0; (* Temperature control threshold *)
    HumidityThreshold : REAL := 5.0; (* Humidity control threshold *)
    TimerElapsed : BOOL := FALSE; (* TRUE if 1 second has elapsed for timer decrement *)
    Timer : TON; (* Timer instance for 1-second intervals *)
END_VAR

(* Main logic of the finite state machine *)
IF NOT OvenStatus THEN
    (* STATE 0: OFF_STATE *)
    State := 0;
    HeatingElement := FALSE;
    CoolingElement := FALSE;
    HumidityControl := FALSE;
    DehumidityControl := FALSE;
    BakingTime := T#0s; (* Reset baking time *)
ELSIF State = 0 THEN
    (* Transition from STATE 0 to STATE 1 *)
    IF OvenStatus THEN
        State := 1;
    END_IF;
END_IF;

CASE State OF
    1: (* STATE 1: PREHEAT_STATE *)
        IF TemperatureSensor < (OvenTemperature - HeatingThreshold) THEN
            HeatingElement := TRUE;
        ELSE
            HeatingElement := FALSE;
        END_IF;
        CoolingElement := FALSE;
        HumidityControl := FALSE;
        DehumidityControl := FALSE;

        (* Transition from STATE 1 to STATE 2 *)
        IF TemperatureSensor >= (OvenTemperature - HeatingThreshold) THEN
            State := 2;
        END_IF;

    2: (* STATE 2: HUMIDITY_ADJUST_STATE *)
        HeatingElement := FALSE;
        CoolingElement := FALSE;

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

        (* Transition from STATE 2 to STATE 3 *)
        IF (HumiditySensor >= (OvenHumidity - HumidityThreshold)) AND (HumiditySensor <= (OvenHumidity + HumidityThreshold)) THEN
            State := 3;
        END_IF;

    3: (* STATE 3: BAKING_STATE *)
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

        (* Timer logic for decrementing baking time *)
        Timer(IN := TRUE, PT := T#1s);
        TimerElapsed := Timer.Q;

        IF TimerElapsed THEN
            BakingTime := BakingTime - T#1s;
            Timer(IN := FALSE); (* Reset timer *)
        END_IF;

        (* Transition from STATE 3 to STATE 4 *)
        IF BakingTime <= T#0s THEN
            State := 4;
        END_IF;

    4: (* STATE 4: COMPLETE_STATE *)
        HeatingElement := FALSE;
        CoolingElement := FALSE;
        HumidityControl := FALSE;
        DehumidityControl := FALSE;

        (* Transition from STATE 4 to STATE 0 *)
        IF NOT OvenStatus THEN
            State := 0;
        END_IF;

    ELSE
        (* Default case to handle unexpected states *)
        State := 0;
END_CASE;
END_FUNCTION_BLOCK
END_ST