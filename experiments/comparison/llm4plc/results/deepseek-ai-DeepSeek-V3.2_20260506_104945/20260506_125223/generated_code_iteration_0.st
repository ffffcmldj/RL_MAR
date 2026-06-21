START_ST
FUNCTION_BLOCK SolarPanelTracking
VAR_INPUT
    CurrentTime : TIME;
    SolarIntensity : REAL;
END_VAR
VAR_OUTPUT
    PanelAngle : REAL;
END_VAR
VAR
    state : INT;
    SunriseTime : TIME := T#6H;
    NoonTime : TIME := T#12H;
    SunsetTime : TIME := T#18H;
    MorningAngle : REAL := 30.0;
    NoonAngle : REAL := 60.0;
    EveningAngle : REAL := 30.0;
END_VAR

(* State definitions:
   0: NIGHT_MODE
   1: MORNING_MODE
   2: EVENING_MODE
   3: INTENSITY_OVERRIDE_MODE
*)

(* Determine next state based on inputs *)
IF SolarIntensity >= 90.0 THEN
    state := 3; (* INTENSITY_OVERRIDE_MODE *)
ELSIF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
    state := 0; (* NIGHT_MODE *)
ELSIF (CurrentTime >= SunriseTime) AND (CurrentTime < NoonTime) THEN
    state := 1; (* MORNING_MODE *)
ELSIF (CurrentTime >= NoonTime) AND (CurrentTime < SunsetTime) THEN
    state := 2; (* EVENING_MODE *)
ELSE
    (* Fallback: keep current state or set to a default *)
    state := state;
END_IF;

(* Set PanelAngle based on the current state *)
CASE state OF
    0: (* NIGHT_MODE *)
        PanelAngle := 0.0;
    1: (* MORNING_MODE *)
        PanelAngle := MorningAngle;
    2: (* EVENING_MODE *)
        PanelAngle := EveningAngle;
    3: (* INTENSITY_OVERRIDE_MODE *)
        PanelAngle := NoonAngle;
    ELSE
        PanelAngle := 0.0; (* Default safe value *)
END_CASE;

END_FUNCTION_BLOCK
END_ST