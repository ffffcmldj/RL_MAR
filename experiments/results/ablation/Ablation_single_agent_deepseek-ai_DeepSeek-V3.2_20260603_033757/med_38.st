FUNCTION_BLOCK SolarPanelTracking
VAR_INPUT
    SolarIntensity : REAL;      (* Input: Solar intensity in percentage *)
    CurrentTime : TIME;         (* Input: Current time of day *)
END_VAR

VAR_OUTPUT
    PanelAngle : REAL := 0.0;   (* Output: Panel angle in degrees *)
END_VAR

VAR
    SunriseTime : TIME := T#6H;    (* Sunrise time set to 6 AM *)
    SunsetTime : TIME := T#18H;    (* Sunset time set to 6 PM *)
    NoonTime : TIME := T#12H;      (* Noon time set to 12 PM *)
    MorningAngle : REAL := 30.0;   (* Angle during morning *)
    NoonAngle : REAL := 60.0;      (* Angle during noon *)
    EveningAngle : REAL := 30.0;   (* Angle during evening *)
END_VAR

(* Main logic *)
IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
    (* Nighttime: set angle to zero *)
    PanelAngle := 0.0;
ELSE
    (* Daytime logic *)
    IF SolarIntensity >= 90.0 THEN
        (* High intensity: use noon angle *)
        PanelAngle := NoonAngle;
    ELSE
        (* Normal intensity: time-based angle selection *)
        IF CurrentTime < NoonTime THEN
            (* Morning: before noon *)
            PanelAngle := MorningAngle;
        ELSE
            (* Evening: after noon *)
            PanelAngle := EveningAngle;
        END_IF;
    END_IF;
END_IF;

(* Ensure angle stays within valid range 0-90 degrees *)
IF PanelAngle < 0.0 THEN
    PanelAngle := 0.0;
ELSIF PanelAngle > 90.0 THEN
    PanelAngle := 90.0;
END_IF;

END_FUNCTION_BLOCK