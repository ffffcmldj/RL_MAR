FUNCTION_BLOCK SolarPanelTracking
VAR_INPUT
    SolarIntensity : REAL;
    CurrentTime : TIME;
END_VAR
VAR_OUTPUT
    PanelAngle : REAL := 0.0;
END_VAR
VAR
    SunriseTime : TIME := T#6H;
    SunsetTime : TIME := T#18H;
    NoonTime : TIME := T#12H;
    MorningAngle : REAL := 30.0;
    NoonAngle : REAL := 60.0;
    EveningAngle : REAL := 30.0;
    IsNight : BOOL;
    IsHighIntensity : BOOL;
    IsMorning : BOOL;
    IsEvening : BOOL;
    TempAngle : REAL;
END_VAR

IsNight := (CurrentTime < SunriseTime) OR (CurrentTime > SunsetTime);

IF IsNight THEN
    PanelAngle := 0.0;
ELSIF SolarIntensity >= 90.0 THEN
    PanelAngle := NoonAngle;
ELSE
    IsMorning := (CurrentTime <= NoonTime);
    IF IsMorning THEN
        TempAngle := MorningAngle;
    ELSE
        TempAngle := EveningAngle;
    END_IF;
    PanelAngle := TempAngle;
END_IF;

IF PanelAngle > 90.0 THEN
    PanelAngle := 90.0;
END_IF;

IF PanelAngle < 0.0 THEN
    PanelAngle := 0.0;
END_IF;

END_FUNCTION_BLOCK