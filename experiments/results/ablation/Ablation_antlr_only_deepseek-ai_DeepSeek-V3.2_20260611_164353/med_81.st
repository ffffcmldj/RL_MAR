FUNCTION_BLOCK SolarPanelTracking
VAR_INPUT
    CurrentTime : TIME;
    SolarIntensity : REAL;
END_VAR

VAR_OUTPUT
    PanelAngle : REAL;
END_VAR

VAR
    SunriseTime : TIME := T#6H;
    NoonTime : TIME := T#12H;
    SunsetTime : TIME := T#18H;
    MorningAngle : REAL := 30.0;
    NoonAngle : REAL := 60.0;
    EveningAngle : REAL := 30.0;
END_VAR

(* Solar intensity override takes precedence *)
IF SolarIntensity >= 90.0 THEN
    PanelAngle := NoonAngle;
ELSE
    (* Time-based tracking logic *)
    IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
        PanelAngle := 0.0; (* Nighttime - panel horizontal *)
    ELSIF (CurrentTime >= SunriseTime) AND (CurrentTime < NoonTime) THEN
        PanelAngle := MorningAngle; (* Morning period *)
    ELSIF (CurrentTime >= NoonTime) AND (CurrentTime < SunsetTime) THEN
        PanelAngle := EveningAngle; (* Afternoon/Evening period *)
    ELSE
        PanelAngle := 0.0; (* Fallback safety position *)
    END_IF;
END_IF;

END_FUNCTION_BLOCK;