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
    
    eState : (STATE_NIGHT, STATE_MORNING, STATE_NOON, STATE_EVENING);
END_VAR

(* Determine state based on time and solar intensity *)
IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
    eState := STATE_NIGHT;
ELSIF SolarIntensity >= 90.0 THEN
    eState := STATE_NOON;
ELSIF CurrentTime < NoonTime THEN
    eState := STATE_MORNING;
ELSE
    eState := STATE_EVENING;
END_IF;

(* Set panel angle based on state *)
CASE eState OF
    STATE_NIGHT:
        PanelAngle := 0.0;
    STATE_MORNING:
        PanelAngle := MorningAngle;
    STATE_NOON:
        PanelAngle := NoonAngle;
    STATE_EVENING:
        PanelAngle := EveningAngle;
END_CASE;

(* Ensure panel angle is within 0 to 90 degrees *)
IF PanelAngle < 0.0 THEN
    PanelAngle := 0.0;
ELSIF PanelAngle > 90.0 THEN
    PanelAngle := 90.0;
END_IF;

END_FUNCTION_BLOCK