ructured-text
START_ST
FUNCTION_BLOCK SolarPanelTracking
VAR_INPUT
    SolarIntensity : REAL;      (* Input: Solar intensity in percentage *)
    CurrentTime : TIME;         (* Input: Current time of day *)
END_VAR

VAR_OUTPUT
    PanelAngle : REAL := 0.0;   (* Output: Panel angle in degrees *)
END_VAR

VAR
    state : INT;                 (* State variable *)
    SunriseTime : TIME := T#6H;    (* Sunrise time set to 6 AM *)
    SunsetTime : TIME := T#18H;     (* Sunset time set to 6 PM *)
    NoonTime : TIME := T#12H;       (* Noon time set to 12 PM *)
    MorningAngle : REAL := 30.0;     (* Angle during morning *)
    NoonAngle : REAL := 60.0;        (* Angle during noon *)
    EveningAngle : REAL := 30.0;      (* Angle during evening *)
END_VAR

(* State definitions *)
IF CurrentTime < SunriseTime THEN
    state := 0;  (* NIGHTTIME *)
ELSIF CurrentTime >= SunriseTime AND CurrentTime < NoonTime THEN
    state := 1;  (* MORNING *)
ELSIF CurrentTime >= NoonTime AND CurrentTime < SunsetTime THEN
    IF SolarIntensity >= 90.0 THEN
        state := 2;  (* NOON *)
    ELSE
        state := 3;  (* EVENING *)
    END_IF
ELSE
    state := 0;  (* NIGHTTIME *)
END_IF

(* Output values based on state *)
CASE state OF
    0: 
        PanelAngle := 0.0;  (* Nighttime, no solar tracking *)
    1: 
        PanelAngle := MorningAngle;  (* Before noon *)
    2: 
        PanelAngle := NoonAngle;  (* After noon and high solar intensity *)
    3: 
        PanelAngle := EveningAngle;  (* After noon and low solar intensity *)
END_CASE

(* Ensure PanelAngle is within 0 to 90 degrees *)
IF PanelAngle < 0.0 THEN
    PanelAngle := 0.0;
ELSIF PanelAngle > 90.0 THEN
    PanelAngle := 90.0;
END_IF

END_FUNCTION_BLOCK
END_ST