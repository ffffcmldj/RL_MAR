ructured-text
FUNCTION_BLOCK EggIncubatorControl
VAR_INPUT
    StartButton : BOOL; (* Input for starting the incubation process *)
    StopButton : BOOL; (* Input for stopping the incubation process *)
    TemperatureSensor : REAL; (* Input for temperature reading in °C *)
    HumiditySensor : REAL; (* Input for humidity reading in % *)
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL; (* Output for controlling the heating element *)
    Humidifier : BOOL; (* Output for controlling the humidifier *)
    EggTurningMotor : BOOL; (* Output for controlling the egg turning motor *)
    IncubationInProgress : BOOL; (* Indicator for an ongoing incubation process *)
END_VAR
VAR
    TargetTemperature : REAL; (* Target temperature in °C *)
    TargetHumidity : REAL; (* Target humidity in % *)
    TurnIntervalSeconds : INT; (* Interval for turning eggs (1 hour in seconds) *)
    TurnTimerSeconds : INT; (* Timer for egg turning cycle in seconds *)
    state : INT; (* Current state variable *)
    prevState : INT; (* Previous state variable *)
END_VAR

(* Initialize control parameters *)
TargetTemperature := 37.5;
TargetHumidity := 50.0;
TurnIntervalSeconds := 3600;
TurnTimerSeconds := 0;
state := 0; (* Initial state: INITIALIZE *)
prevState := 0;

(* State Machine Logic *)
CASE state OF
    0: (* INITIALIZE *)
        HeatingElement := FALSE;
        Humidifier := FALSE;
        EggTurningMotor := FALSE;
        IncubationInProgress := FALSE;
        state := 1; (* Transition to IDLE state *)

    1: (* IDLE *)
        HeatingElement := FALSE;
        Humidifier := FALSE;
        EggTurningMotor := FALSE;
        IncubationInProgress := FALSE;
        IF StartButton THEN
            IF NOT IncubationInProgress THEN
                state := 2; (* Transition to INCUBATING state *)
            END_IF;
        END_IF;

    2: (* INCUBATING *)
        IncubationInProgress := TRUE;
        (* Temperature Control *)
        IF TemperatureSensor < TargetTemperature THEN
            HeatingElement := TRUE;
        ELSE
            HeatingElement := FALSE;
        END_IF;

        (* Humidity Control *)
        IF HumiditySensor < TargetHumidity THEN
            Humidifier := TRUE;
        ELSE
            Humidifier := FALSE;
        END_IF;

        (* Egg Turning Cycle *)
        TurnTimerSeconds := TurnTimerSeconds + 1; (* Increment timer each cycle *)
        IF TurnTimerSeconds >= TurnIntervalSeconds THEN
            EggTurningMotor := NOT EggTurningMotor; (* Toggle EggTurningMotor state *)
            TurnTimerSeconds := 0; (* Reset timer *)
        END_IF;

        IF StopButton THEN
            state := 1; (* Transition back to IDLE state *)
            HeatingElement := FALSE;
            Humidifier := FALSE;
            EggTurningMotor := FALSE;
            IncubationInProgress := FALSE;
            TurnTimerSeconds := 0; (* Reset timer *)
        END_IF;

END_CASE;

END_FUNCTION_BLOCK