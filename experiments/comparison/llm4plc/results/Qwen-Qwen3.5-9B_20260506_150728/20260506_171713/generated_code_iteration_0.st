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
    TargetTemperature : REAL; (* Target temperature in °C *)
    TargetHumidity : REAL; (* Target humidity in % *)
    TurnIntervalSeconds : INT; (* Interval for turning eggs (1 hour in seconds) *)
    TurnTimerSeconds : INT; (* Timer for egg turning cycle in seconds *)
    CurrentState : INT; (* State variable for Finite State Machine *)
END_VAR

(* Initialize control parameters *)
TargetTemperature := 37.5;
TargetHumidity := 50.0;
TurnIntervalSeconds := 3600;
TurnTimerSeconds := 0;
CurrentState := 0; (* Initialize to IDLE state *)

(* State Transition Logic *)
(* Transition from STATE 0 (IDLE) to STATE 1 (RUNNING) *)
IF (StartButton = TRUE) AND (CurrentState = 0) THEN
    CurrentState := 1;
    IncubationInProgress := TRUE;
    TurnTimerSeconds := 0;
ELSIF (StopButton = TRUE) AND (CurrentState = 1) THEN
    (* Transition from STATE 1 (RUNNING) to STATE 0 (IDLE) *)
    CurrentState := 0;
    IncubationInProgress := FALSE;
    TurnTimerSeconds := 0;
END_IF;

(* Output Logic based on Current State *)
IF CurrentState = 0 THEN
    (* STATE 0: IDLE - All outputs OFF *)
    HeatingElement := FALSE;
    Humidifier := FALSE;
    EggTurningMotor := FALSE;
    IncubationInProgress := FALSE;
ELSIF CurrentState = 1 THEN
    (* STATE 1: RUNNING *)
    
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
    
    (* Egg Turning Cycle Logic *)
    TurnTimerSeconds := TurnTimerSeconds + 1;
    
    IF TurnTimerSeconds >= TurnIntervalSeconds THEN
        (* Toggle Motor State *)
        IF EggTurningMotor = FALSE THEN
            EggTurningMotor := TRUE;
        ELSE
            EggTurningMotor := FALSE;
        END_IF;
        TurnTimerSeconds := 0;
    END_IF;
    
    (* Ensure Incubation Status is Active *)
    IncubationInProgress := TRUE;
END_IF;

END_FUNCTION_BLOCK
END_ST