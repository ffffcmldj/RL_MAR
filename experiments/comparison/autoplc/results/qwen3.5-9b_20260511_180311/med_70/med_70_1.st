FUNCTION_BLOCK EggIncubatorControl
VAR_INPUT
    StartButton : BOOL;
    StopButton : BOOL;
    TemperatureSensor : REAL;
    HumiditySensor : REAL;
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL;
    Humidifier : BOOL;
    EggTurningMotor : BOOL;
    IncubationInProgress : BOOL;
END_VAR
VAR
    TargetTemperature : REAL;
    TargetHumidity : REAL;
    TurnIntervalSeconds : INT;
    TurnTimerSeconds : INT;
END_VAR

TargetTemperature := 37.5;
TargetHumidity := 50.0;
TurnIntervalSeconds := 3600;
TurnTimerSeconds := 0;

IF StopButton = TRUE THEN
    IncubationInProgress := FALSE;
    HeatingElement := FALSE;
    Humidifier := FALSE;
    EggTurningMotor := FALSE;
    TurnTimerSeconds := 0;
ELSIF StartButton = TRUE AND IncubationInProgress = FALSE THEN
    IncubationInProgress := TRUE;
ELSE
    IF IncubationInProgress = TRUE THEN
        IF TemperatureSensor < TargetTemperature THEN
            HeatingElement := TRUE;
        ELSE
            HeatingElement := FALSE;
        END_IF;

        IF HumiditySensor < TargetHumidity THEN
            Humidifier := TRUE;
        ELSE
            Humidifier := FALSE;
        END_IF;

        TurnTimerSeconds := TurnTimerSeconds + 1;

        IF TurnTimerSeconds >= TurnIntervalSeconds THEN
            IF EggTurningMotor = TRUE THEN
                EggTurningMotor := FALSE;
            ELSE
                EggTurningMotor := TRUE;
            END_IF;
            TurnTimerSeconds := 0;
        END_IF;
    END_IF;
END_IF;

END_FUNCTION_BLOCK