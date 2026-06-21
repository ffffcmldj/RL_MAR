FUNCTION_BLOCK GreenhouseWateringSystem
VAR_INPUT
    SoilMoistureSensor : REAL;
END_VAR
VAR_OUTPUT
    SprinklersOn : BOOL;
END_VAR
VAR
    ResponseDelay : TIME;
    LastMoistureReading : REAL;
    LastStateChangeTime : TIME;
    CurrentState : BOOL;
    DelayElapsed : BOOL;
    TimeSinceLastChange : TIME;
    Now : TIME;
END_VAR

SprinklersOn := FALSE;
LastMoistureReading := SoilMoistureSensor;
Now := T#0s;

IF ResponseDelay = T#0s THEN
    DelayElapsed := TRUE;
ELSE
    TimeSinceLastChange := Now - LastStateChangeTime;
    IF TimeSinceLastChange >= ResponseDelay THEN
        DelayElapsed := TRUE;
    ELSE
        DelayElapsed := FALSE;
    END_IF;
END_IF;

IF CurrentState = FALSE THEN
    IF SoilMoistureSensor < 30.0 AND DelayElapsed THEN
        CurrentState := TRUE;
        LastStateChangeTime := Now;
    END_IF;
ELSE
    IF SoilMoistureSensor > 70.0 AND DelayElapsed THEN
        CurrentState := FALSE;
        LastStateChangeTime := Now;
    END_IF;
END_IF;

SprinklersOn := CurrentState;
LastMoistureReading := SoilMoistureSensor;

END_FUNCTION_BLOCK