START_ST
FUNCTION_BLOCK EggIncubatorControl
VAR_INPUT
    StartButton : BOOL;
    StopButton : BOOL;
    TemperatureSensor : REAL;
    HumiditySensor : REAL;
    OneSecondPulse : BOOL; (* External 1-second clock pulse for timer increment *)
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL;
    Humidifier : BOOL;
    EggTurningMotor : BOOL;
    IncubationInProgress : BOOL;
END_VAR
VAR
    state : INT; (* 0 = IDLE, 1 = INCUBATION_ACTIVE *)
    prevState : INT;
    TurnTimerSeconds : INT;
    EggTurningMotorState : BOOL;
    TargetTemperature : REAL;
    TargetHumidity : REAL;
    TurnIntervalSeconds : INT;
END_VAR

(* Initialization *)
TargetTemperature := 37.5;
TargetHumidity := 50.0;
TurnIntervalSeconds := 3600;
TurnTimerSeconds := 0;
EggTurningMotorState := FALSE;
HeatingElement := FALSE;
Humidifier := FALSE;
EggTurningMotor := FALSE;
IncubationInProgress := FALSE;
state := 0;
prevState := 0;

(* State Machine Execution *)
CASE state OF
    0: (* IDLE State *)
        HeatingElement := FALSE;
        Humidifier := FALSE;
        EggTurningMotor := FALSE;
        IncubationInProgress := FALSE;
        TurnTimerSeconds := 0;
        EggTurningMotorState := FALSE;
        
        IF StartButton AND NOT IncubationInProgress THEN
            state := 1;
        END_IF;
        
    1: (* INCUBATION_ACTIVE State *)
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
        
        (* Egg Turning Timer Handling *)
        IF OneSecondPulse THEN
            TurnTimerSeconds := TurnTimerSeconds + 1;
        END_IF;
        
        IF TurnTimerSeconds >= TurnIntervalSeconds THEN
            EggTurningMotorState := NOT EggTurningMotorState;
            EggTurningMotor := EggTurningMotorState;
            TurnTimerSeconds := 0;
        ELSE
            EggTurningMotor := EggTurningMotorState;
        END_IF;
        
        (* Transition to IDLE on StopButton press *)
        IF StopButton THEN
            state := 0;
        END_IF;
        
END_CASE;

(* Update previous state for potential edge detection or debugging *)
prevState := state;

END_FUNCTION_BLOCK
END_ST