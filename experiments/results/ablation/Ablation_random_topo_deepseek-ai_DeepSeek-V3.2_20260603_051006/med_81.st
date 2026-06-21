FUNCTION_BLOCK SolarPanelTracking
VAR
    PanelAngle : REAL; (* Output for adjusting the solar panel angle *)
    SunriseTime : TIME := T#6H; (* Set the time for sunrise (6:00 AM) *)
    SunsetTime : TIME := T#18H; (* Set the time for sunset (6:00 PM) *)
    NoonTime : TIME := T#12H; (* Set the time for solar noon (12:00 PM) *)
    MorningAngle : REAL := 30.0; (* Set the morning angle for panels *)
    NoonAngle : REAL := 60.0; (* Set the noon angle for panels *)
    EveningAngle : REAL := 30.0; (* Set the evening angle for panels *)
END_VAR
VAR_INPUT
    CurrentTime : TIME;
    SolarIntensity : REAL;
END_VAR

(* Main execution logic *)
IF SolarIntensity >= 90.0 THEN
    (* Solar intensity override - maximum energy capture *)
    PanelAngle := NoonAngle;
ELSE
    (* Time-based tracking logic *)
    IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
        (* Nighttime - panel horizontal *)
        PanelAngle := 0.0;
    ELSIF (CurrentTime >= SunriseTime) AND (CurrentTime < NoonTime) THEN
        (* Morning period *)
        PanelAngle := MorningAngle;
    ELSE
        (* Afternoon/Evening period (NoonTime <= CurrentTime < SunsetTime) *)
        PanelAngle := EveningAngle;
    END_IF;
END_IF;

END_FUNCTION_BLOCK