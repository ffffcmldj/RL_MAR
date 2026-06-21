FUNCTION_BLOCK EggIncubatorControl
VAR_INPUT
    StartButton : BOOL;           (* Momentary button to start incubation *)
    StopButton : BOOL;            (* Momentary button to stop incubation *)
    TemperatureSensor : REAL;     (* Current temperature in °C *)
    HumiditySensor : REAL;        (* Current humidity in % *)
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL;        (* Controls heating element *)
    Humidifier : BOOL;            (* Controls humidifier *)
    EggTurningMotor : BOOL;       (* Controls egg turning motor *)
    IncubationInProgress : BOOL;  (* Indicates if incubation is active *)
END_VAR
VAR
    TargetTemperature : REAL;     (* Target temperature setpoint *)
    TargetHumidity : REAL;        (* Target humidity setpoint *)
    TurnIntervalSeconds : INT;    (* Time interval for egg turning *)
    TurnTimerSeconds : INT;       (* Timer for egg turning cycle *)
    TurnMotorState : BOOL;        (* Internal state for motor toggle *)
END_VAR

(* Initialization of parameters *)
TargetTemperature := 37.5;
TargetHumidity := 50.0;
TurnIntervalSeconds := 3600;

(* Main control logic *)
IF StopButton THEN
    (* Emergency/Manual Stop: Reset all outputs and timers *)
    IncubationInProgress := FALSE;
    HeatingElement := FALSE;
    Humidifier := FALSE;
    EggTurningMotor := FALSE;
    TurnTimerSeconds := 0;
    TurnMotorState := FALSE;
ELSIF StartButton AND NOT IncubationInProgress THEN
    (* Start incubation process *)
    IncubationInProgress := TRUE;
    TurnTimerSeconds := 0;
    TurnMotorState := FALSE;
END_IF;

(* Temperature Control - only active when incubation is in progress *)
IF IncubationInProgress THEN
    HeatingElement := TemperatureSensor < TargetTemperature;
ELSE
    HeatingElement := FALSE;
END_IF;

(* Humidity Control - only active when incubation is in progress *)
IF IncubationInProgress THEN
    Humidifier := HumiditySensor < TargetHumidity;
ELSE
    Humidifier := FALSE;
END_IF;

(* Egg Turning Cycle - only active when incubation is in progress *)
IF IncubationInProgress THEN
    (* Increment timer each scan cycle *)
    TurnTimerSeconds := TurnTimerSeconds + 1;
    
    (* Check if turning interval has been reached *)
    IF TurnTimerSeconds >= TurnIntervalSeconds THEN
        (* Toggle motor state and reset timer *)
        TurnMotorState := NOT TurnMotorState;
        TurnTimerSeconds := 0;
    END_IF;
    
    (* Output motor state *)
    EggTurningMotor := TurnMotorState;
ELSE
    (* When not in progress, ensure motor is off *)
    EggTurningMotor := FALSE;
    TurnTimerSeconds := 0;
    TurnMotorState := FALSE;
END_IF;

END_FUNCTION_BLOCK