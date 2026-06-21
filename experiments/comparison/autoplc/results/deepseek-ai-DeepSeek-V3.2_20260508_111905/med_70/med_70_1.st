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
    StartButtonPrev : BOOL; (* Previous state of StartButton for edge detection *)
    bInitialized : BOOL; (* Flag to track initialization *)
END_VAR

(* Initialization *)
IF NOT bInitialized THEN
    TargetTemperature := 37.5;
    TargetHumidity := 50.0;
    TurnIntervalSeconds := 3600;
    TurnTimerSeconds := 0;
    HeatingElement := FALSE;
    Humidifier := FALSE;
    EggTurningMotor := FALSE;
    IncubationInProgress := FALSE;
    StartButtonPrev := FALSE;
    bInitialized := TRUE;
END_IF

(* Start/Stop Control *)
IF StopButton THEN
    (* Immediate stop when StopButton is pressed *)
    IncubationInProgress := FALSE;
ELSIF StartButton AND NOT StartButtonPrev AND NOT IncubationInProgress THEN
    (* Start when StartButton has rising edge and process is not already in progress *)
    IncubationInProgress := TRUE;
END_IF

(* Store current StartButton state for next cycle edge detection *)
StartButtonPrev := StartButton;

(* Temperature Control *)
IF IncubationInProgress THEN
    HeatingElement := TemperatureSensor < TargetTemperature;
ELSE
    HeatingElement := FALSE;
END_IF

(* Humidity Control *)
IF IncubationInProgress THEN
    Humidifier := HumiditySensor < TargetHumidity;
ELSE
    Humidifier := FALSE;
END_IF

(* Egg Turning Cycle *)
IF IncubationInProgress THEN
    (* Increment timer *)
    TurnTimerSeconds := TurnTimerSeconds + 1;
    
    (* Check if turning interval reached *)
    IF TurnTimerSeconds >= TurnIntervalSeconds THEN
        (* Toggle motor state *)
        EggTurningMotor := NOT EggTurningMotor;
        (* Reset timer *)
        TurnTimerSeconds := 0;
    END_IF;
ELSE
    (* Process not in progress - turn off motor and reset timer *)
    EggTurningMotor := FALSE;
    TurnTimerSeconds := 0;
END_IF

END_FUNCTION_BLOCK