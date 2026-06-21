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
    State : INT := 0;              (* State variable for state machine *)
END_VAR

(* Main state machine logic *)
CASE State OF
    0: (* INIT *)
        PanelAngle := 0.0;
        State := 1;
        
    1: (* CHECK_TIME *)
        IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
            State := 2;
        ELSIF (CurrentTime < NoonTime) THEN
            State := 3;
        ELSE
            State := 4;
        END_IF;
        
    2: (* NIGHTTIME *)
        PanelAngle := 0.0;
        State := 1;
        
    3: (* MORNING *)
        PanelAngle := MorningAngle;
        IF (SolarIntensity >= 90.0) THEN
            State := 5;
        ELSE
            State := 1;
        END_IF;
        
    4: (* AFTERNOON_EVENING *)
        PanelAngle := EveningAngle;
        IF (SolarIntensity >= 90.0) THEN
            State := 5;
        ELSE
            State := 1;
        END_IF;
        
    5: (* HIGH_INTENSITY *)
        PanelAngle := NoonAngle;
        State := 1;
        
    ELSE
        State := 0;
END_CASE;

(* Apply boundary limits to ensure angle stays within 0-90 degrees *)
IF PanelAngle < 0.0 THEN
    PanelAngle := 0.0;
ELSIF PanelAngle > 90.0 THEN
    PanelAngle := 90.0;
END_IF;

END_FUNCTION_BLOCK;