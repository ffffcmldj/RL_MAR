FUNCTION_BLOCK EggIncubatorControl
VAR_INPUT
    StartButton : BOOL;        (* Input for starting the incubation process *)
    StopButton : BOOL;         (* Input for stopping the incubation process *)
    TemperatureSensor : REAL;  (* Input for temperature reading in °C *)
    HumiditySensor : REAL;     (* Input for humidity reading in % *)
END_VAR

VAR_OUTPUT
    HeatingElement : BOOL;     (* Output for controlling the heating element *)
    Humidifier : BOOL;         (* Output for controlling the humidifier *)
    EggTurningMotor : BOOL;    (* Output for controlling the egg turning motor *)
    IncubationInProgress : BOOL; (* Indicator for an ongoing incubation process *)
END_VAR

VAR
    TargetTemperature : REAL;  (* Target temperature in °C *)
    TargetHumidity : REAL;     (* Target humidity in % *)
    TurnIntervalSeconds : INT; (* Interval for turning eggs (1 hour in seconds) *)
    TurnTimerSeconds : INT;    (* Timer for egg turning cycle in seconds *)
END_VAR

(* Initialize control parameters *)
TargetTemperature := 37.5;
TargetHumidity := 50.0;
TurnIntervalSeconds := 3600;

(* Process Start/Stop Control *)
IF StopButton THEN
    IncubationInProgress := FALSE;
    HeatingElement := FALSE;
    Humidifier := FALSE;
    EggTurningMotor := FALSE;
    TurnTimerSeconds := 0;
ELSIF StartButton AND NOT IncubationInProgress THEN
    IncubationInProgress := TRUE;
    TurnTimerSeconds := 0;
END_IF;

(* Process Temperature Control *)
IF IncubationInProgress AND (TemperatureSensor < TargetTemperature) THEN
    HeatingElement := TRUE;
ELSE
    HeatingElement := FALSE;
END_IF;

(* Process Humidity Control *)
IF IncubationInProgress AND (HumiditySensor < TargetHumidity) THEN
    Humidifier := TRUE;
ELSE
    Humidifier := FALSE;
END_IF;

(* Process Egg Turning Cycle *)
IF IncubationInProgress THEN
    TurnTimerSeconds := TurnTimerSeconds + 1;
    
    IF TurnTimerSeconds >= TurnIntervalSeconds THEN
        EggTurningMotor := NOT EggTurningMotor;
        TurnTimerSeconds := 0;
    END_IF;
ELSE
    EggTurningMotor := FALSE;
    TurnTimerSeconds := 0;
END_IF;

END_FUNCTION_BLOCK