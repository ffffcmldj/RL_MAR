FUNCTION_BLOCK EggIncubatorControl
VAR_INPUT
    StartButton : BOOL;          (* Rising edge triggers start *)
    StopButton : BOOL;           (* Rising edge triggers stop *)
    TemperatureSensor : REAL;    (* Current temperature in °C *)
    HumiditySensor : REAL;       (* Current humidity in % *)
END_VAR

VAR_OUTPUT
    HeatingElement : BOOL;       (* Controls heating element *)
    Humidifier : BOOL;           (* Controls humidifier *)
    EggTurningMotor : BOOL;      (* Controls turning motor *)
    IncubationInProgress : BOOL; (* Process status indicator *)
END_VAR

VAR
    TargetTemperature : REAL := 37.5;    (* Default target temperature *)
    TargetHumidity : REAL := 50.0;       (* Default target humidity *)
    TurnIntervalSeconds : INT := 3600;   (* Default turn interval *)
    TurnTimerSeconds : INT := 0;         (* Timer for turning cycle *)
    
    (* Edge detection for buttons *)
    StartButtonPrev : BOOL := FALSE;
    StopButtonPrev : BOOL := FALSE;
END_VAR

(* Edge detection for StartButton *)
IF StartButton AND NOT StartButtonPrev THEN
    (* Start condition: only if not already in progress *)
    IF NOT IncubationInProgress THEN
        IncubationInProgress := TRUE;
        TurnTimerSeconds := 0;
    END_IF;
END_IF;

(* Edge detection for StopButton *)
IF StopButton AND NOT StopButtonPrev THEN
    (* Immediate stop with reset *)
    IncubationInProgress := FALSE;
    HeatingElement := FALSE;
    Humidifier := FALSE;
    EggTurningMotor := FALSE;
    TurnTimerSeconds := 0;
END_IF;

(* Temperature control - only active when incubation is in progress *)
IF IncubationInProgress THEN
    HeatingElement := TemperatureSensor < TargetTemperature;
ELSE
    HeatingElement := FALSE;
END_IF;

(* Humidity control - only active when incubation is in progress *)
IF IncubationInProgress THEN
    Humidifier := HumiditySensor < TargetHumidity;
ELSE
    Humidifier := FALSE;
END_IF;

(* Egg turning cycle - only active when incubation is in progress *)
IF IncubationInProgress THEN
    (* Increment timer *)
    TurnTimerSeconds := TurnTimerSeconds + 1;
    
    (* Check if turn interval reached *)
    IF TurnTimerSeconds >= TurnIntervalSeconds THEN
        (* Toggle motor state *)
        EggTurningMotor := NOT EggTurningMotor;
        (* Reset timer *)
        TurnTimerSeconds := 0;
    END_IF;
ELSE
    (* Reset timer and motor when not in progress *)
    TurnTimerSeconds := 0;
    EggTurningMotor := FALSE;
END_IF;

(* Store previous button states for edge detection *)
StartButtonPrev := StartButton;
StopButtonPrev := StopButton;

END_FUNCTION_BLOCK