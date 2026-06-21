FUNCTION_BLOCK SolarPanelTracking
VAR
 PanelAngle : REAL;
 SunriseTime : TIME := T#6H;
 SunsetTime : TIME := T#18H;
 NoonTime : TIME := T#12H;
 MorningAngle : REAL := 30.0;
 NoonAngle : REAL := 60.0;
 EveningAngle : REAL := 30.0;
END_VAR
VAR_INPUT
 CurrentTime : TIME;
 SolarIntensity : REAL;
END_VAR
VAR
 HighIntensityFlag : BOOL;
 TimeBasedAngle : REAL;
END_VAR

HighIntensityFlag := FALSE;
IF SolarIntensity >= 90.0 THEN
    HighIntensityFlag := TRUE;
END_IF;

IF HighIntensityFlag = TRUE THEN
    PanelAngle := NoonAngle;
ELSE
    TimeBasedAngle := 0.0;
    IF CurrentTime < SunriseTime OR CurrentTime >= SunsetTime THEN
        TimeBasedAngle := 0.0;
    ELSIF CurrentTime >= SunriseTime AND CurrentTime < NoonTime THEN
        TimeBasedAngle := MorningAngle;
    ELSE
        TimeBasedAngle := EveningAngle;
    END_IF;
    PanelAngle := TimeBasedAngle;
END_IF;

END_FUNCTION_BLOCK