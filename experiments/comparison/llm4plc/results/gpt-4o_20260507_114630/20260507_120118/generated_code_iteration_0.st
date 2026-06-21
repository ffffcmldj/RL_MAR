plaintext
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
    SunriseTime : TIME := T#6H;        (* Sunrise time set to 6 AM *)
    SunsetTime : TIME := T#18H;        (* Sunset time set to 6 PM *)
    NoonTime : TIME := T#12H;          (* Noon time set to 12 PM *)
    MorningAngle : REAL := 30.0;       (* Angle during morning *)
    NoonAngle : REAL := 60.0;          (* Angle during noon *)
    EveningAngle : REAL := 30.0;       (* Angle during evening *)
    state : INT := 0;                  (* Current state of the system *)
    prevState : INT := -1;             (* Previous state of the system *)
END_VAR

(* State Definitions *)
(* STATE 0: NIGHTTIME *)
(* STATE 1: MORNING *)
(* STATE 2: NOON *)
(* STATE 3: EVENING *)

(* Finite State Machine Logic *)
IF CurrentTime < SunriseTime OR CurrentTime >= SunsetTime THEN
    (* Transition to NIGHTTIME state *)
    state := 0;
ELSIF CurrentTime >= SunriseTime AND CurrentTime < NoonTime THEN
    IF SolarIntensity >= 90.0 THEN
        (* Transition to NOON state *)
        state := 2;
    ELSE
        (* Transition to MORNING state *)
        state := 1;
    END_IF;
ELSIF CurrentTime >= NoonTime AND CurrentTime < SunsetTime THEN
    IF SolarIntensity >= 90.0 THEN
        (* Transition to NOON state *)
        state := 2;
    ELSE
        (* Transition to EVENING state *)
        state := 3;
    END_IF;
END_IF;

(* Handle transitions between states *)
CASE state OF
    0: (* NIGHTTIME *)
        PanelAngle := 0.0;
    1: (* MORNING *)
        PanelAngle := MorningAngle;
    2: (* NOON *)
        PanelAngle := NoonAngle;
    3: (* EVENING *)
        PanelAngle := EveningAngle;
END_CASE;

(* Ensure PanelAngle remains within bounds (0 to 90 degrees) *)
IF PanelAngle < 0.0 THEN
    PanelAngle := 0.0;
ELSIF PanelAngle > 90.0 THEN
    PanelAngle := 90.0;
END_IF;

(* Update previous state for debugging or future use *)
prevState := state;

END_FUNCTION_BLOCK
END_ST