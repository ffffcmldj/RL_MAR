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
    State : INT := 1;              (* Current state *)
    NextState : INT := 1;          (* Next state *)
END_VAR

(* State machine execution *)
State := NextState;

CASE State OF
    1: (* Night/Off State *)
        PanelAngle := 0.0;
        IF (CurrentTime >= SunriseTime) AND (CurrentTime < SunsetTime) THEN
            NextState := 2;  (* Transition to daytime active *)
        ELSE
            NextState := 1;  (* Stay in night state *)
        END_IF;

    2: (* Daytime Active State - Decision making state *)
        IF (SolarIntensity >= 90.0) THEN
            NextState := 3;  (* High intensity -> noon angle *)
        ELSIF (CurrentTime < NoonTime) THEN
            NextState := 4;  (* Morning -> morning angle *)
        ELSE
            NextState := 5;  (* Afternoon -> evening angle *)
        END_IF;

    3: (* High Intensity Noon Angle State *)
        PanelAngle := NoonAngle;
        IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
            NextState := 1;  (* Transition to night *)
        ELSIF (SolarIntensity < 90.0) THEN
            NextState := 2;  (* Intensity dropped -> reevaluate *)
        ELSE
            NextState := 3;  (* Stay in high intensity state *)
        END_IF;

    4: (* Morning Angle State *)
        PanelAngle := MorningAngle;
        IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
            NextState := 1;  (* Transition to night *)
        ELSIF (CurrentTime >= NoonTime) OR (SolarIntensity >= 90.0) THEN
            NextState := 2;  (* Time passed noon or high intensity -> reevaluate *)
        ELSE
            NextState := 4;  (* Stay in morning state *)
        END_IF;

    5: (* Evening Angle State *)
        PanelAngle := EveningAngle;
        IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
            NextState := 1;  (* Transition to night *)
        ELSIF (CurrentTime < NoonTime) OR (SolarIntensity >= 90.0) THEN
            NextState := 2;  (* Time before noon or high intensity -> reevaluate *)
        ELSE
            NextState := 5;  (* Stay in evening state *)
        END_IF;

    ELSE  (* Default case for invalid state *)
        NextState := 1;
        PanelAngle := 0.0;
END_CASE;

(* Ensure panel angle stays within 0 to 90 degrees *)
IF PanelAngle < 0.0 THEN
    PanelAngle := 0.0;
ELSIF PanelAngle > 90.0 THEN
    PanelAngle := 90.0;
END_IF;

END_FUNCTION_BLOCK