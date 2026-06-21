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
    State : INT := 0;              (* Current state *)
    NextState : INT := 0;          (* Next state *)
END_VAR

(* State machine implementation *)
CASE State OF
    0: (* INIT *)
        PanelAngle := 0.0;
        NextState := 1;
        
    1: (* CHECK_TIME *)
        IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
            NextState := 2; (* NIGHT *)
        ELSIF (CurrentTime >= SunriseTime) AND (CurrentTime < NoonTime) THEN
            NextState := 3; (* MORNING *)
        ELSIF (CurrentTime >= NoonTime) AND (CurrentTime < SunsetTime) THEN
            NextState := 4; (* AFTERNOON *)
        ELSE
            NextState := 2; (* Default to NIGHT for safety *)
        END_IF;
        
    2: (* NIGHT *)
        PanelAngle := 0.0;
        IF (CurrentTime >= SunriseTime) AND (CurrentTime < SunsetTime) THEN
            NextState := 1; (* Return to CHECK_TIME *)
        ELSE
            NextState := 2; (* Stay in NIGHT *)
        END_IF;
        
    3: (* MORNING *)
        PanelAngle := MorningAngle;
        IF SolarIntensity >= 90.0 THEN
            NextState := 5; (* HIGH_INTENSITY *)
        ELSIF CurrentTime >= NoonTime THEN
            NextState := 1; (* Return to CHECK_TIME *)
        ELSE
            NextState := 3; (* Stay in MORNING *)
        END_IF;
        
    4: (* AFTERNOON *)
        PanelAngle := EveningAngle;
        IF SolarIntensity >= 90.0 THEN
            NextState := 5; (* HIGH_INTENSITY *)
        ELSIF (CurrentTime < NoonTime) OR (CurrentTime >= SunsetTime) THEN
            NextState := 1; (* Return to CHECK_TIME *)
        ELSE
            NextState := 4; (* Stay in AFTERNOON *)
        END_IF;
        
    5: (* HIGH_INTENSITY *)
        PanelAngle := NoonAngle;
        IF SolarIntensity < 90.0 THEN
            NextState := 1; (* Return to CHECK_TIME *)
        ELSIF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
            NextState := 2; (* Transition to NIGHT *)
        ELSE
            NextState := 5; (* Stay in HIGH_INTENSITY *)
        END_IF;
        
    ELSE
        (* Invalid state - reset to INIT *)
        State := 0;
        NextState := 0;
END_CASE;

(* Update state for next execution cycle *)
State := NextState;

(* CRITICAL: Ensure panel angle stays within 0 to 90 degrees *)
(* This handles both internal parameter errors and any edge cases *)
IF PanelAngle < 0.0 THEN
    PanelAngle := 0.0;
ELSIF PanelAngle > 90.0 THEN
    PanelAngle := 90.0;
END_IF;

END_FUNCTION_BLOCK