FUNCTION_BLOCK FishTankControl
VAR_INPUT
    OxygenLevel : REAL;
    WaterTemperature : REAL;
    FeedingTime : TIME;
    CurrentTime : TIME;
END_VAR
VAR_OUTPUT
    OxygenValve : BOOL;
    Heater : BOOL;
    Feeder : BOOL;
END_VAR

IF OxygenLevel < 5.0 THEN
    OxygenValve := TRUE;
ELSE
    OxygenValve := FALSE;
END_IF

IF WaterTemperature < 25.0 THEN
    Heater := TRUE;
ELSE
    Heater := FALSE;
END_IF

IF CurrentTime >= FeedingTime THEN
    Feeder := TRUE;
ELSE
    Feeder := FALSE;
END_IF

END_FUNCTION_BLOCK