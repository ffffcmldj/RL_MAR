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
    State : INT := 0;
    NextState : INT := 0;
END_VAR

CASE State OF
    0: (* INIT *)
        PanelAngle := 0.0;
        SunriseTime := T#6H;
        SunsetTime := T#18H;
        NoonTime := T#12H;
        MorningAngle := 30.0;
        NoonAngle := 60.0;
        EveningAngle := 30.0;
        NextState := 1;
        
    1: (* CHECK_TIME *)
        IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
            NextState := 2;  (* NIGHTTIME *)
        ELSIF (CurrentTime >= SunriseTime) AND (CurrentTime < NoonTime) THEN
            NextState := 3;  (* MORNING *)
        ELSIF (CurrentTime >= NoonTime) AND (CurrentTime < SunsetTime) THEN
            NextState := 4;  (* AFTERNOON *)
        ELSE
            NextState := 1;  (* Stay in CHECK_TIME *)
        END_IF;
        
    2: (* NIGHTTIME *)
        PanelAngle := 0.0;
        NextState := 1;
        
    3: (* MORNING *)
        IF SolarIntensity >= 90.0 THEN
            PanelAngle := NoonAngle;
        ELSE
            PanelAngle := MorningAngle;
        END_IF;
        
        (* Clamp angle to 0-90 degrees *)
        IF PanelAngle < 0.0 THEN
            PanelAngle := 0.0;
        ELSIF PanelAngle > 90.0 THEN
            PanelAngle := 90.0;
        END_IF;
        NextState := 1;
        
    4: (* AFTERNOON *)
        IF SolarIntensity >= 90.0 THEN
            PanelAngle := NoonAngle;
        ELSE
            PanelAngle := EveningAngle;
        END_IF;
        
        (* Clamp angle to 0-90 degrees *)
        IF PanelAngle < 0.0 THEN
            PanelAngle := 0.0;
        ELSIF PanelAngle > 90.0 THEN
            PanelAngle := 90.0;
        END_IF;
        NextState := 1;
        
END_CASE;

State := NextState;

END_FUNCTION_BLOCK