plaintext
START_ST
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
    TargetTemperature : REAL := 37.5; (* Target temperature in °C *)
    TargetHumidity : REAL := 50.0; (* Target humidity in % *)
    TurnIntervalSeconds : INT := 3600; (* Interval for turning eggs (1 hour in seconds) *)
    TurnTimerSeconds : INT := 0; (* Timer for egg turning cycle in seconds *)
    state : INT := 0; (* Current state of the FSM *)
    prevState : INT := 0; (* Previous state of the FSM for tracking purposes *)
END_VAR

(* FSM Logic *)
CASE state OF
    (* STATE 0: IDLE *)
    0:
        HeatingElement := FALSE;
        Humidifier := FALSE;
        EggTurningMotor := FALSE;
        IncubationInProgress := FALSE;
        TurnTimerSeconds := 0;

        IF StartButton AND NOT IncubationInProgress THEN
            state := 1; (* Transition to STATE 1: INCUBATION *)
        END_IF;

    (* STATE 1: INCUBATION *)
    1:
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
        TurnTimerSeconds := TurnTimerSeconds + 1;
        IF TurnTimerSeconds >= TurnIntervalSeconds THEN
            EggTurningMotor := NOT EggTurningMotor; (* Toggle EggTurningMotor *)
            TurnTimerSeconds := 0; (* Reset TurnTimerSeconds *)
        END_IF;

        (* Transition to STATE 2: STOP if StopButton is pressed *)
        IF StopButton THEN
            state := 2;
        END_IF;

    (* STATE 2: STOP *)
    2:
        HeatingElement := FALSE;
        Humidifier := FALSE;
        EggTurningMotor := FALSE;
        IncubationInProgress := FALSE;
        TurnTimerSeconds := 0;

        (* Transition back to STATE 0: IDLE *)
        state := 0;

END_CASE;

(* Store the previous state for debugging or tracking purposes *)
prevState := state;

END_FUNCTION_BLOCK
END_ST