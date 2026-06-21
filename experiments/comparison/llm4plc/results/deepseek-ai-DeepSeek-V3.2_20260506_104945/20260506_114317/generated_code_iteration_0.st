START_ST
FUNCTION_BLOCK SolarPanelTracking
VAR_INPUT
    SolarIntensity : REAL;
    CurrentTime : TIME;
END_VAR

VAR_OUTPUT
    PanelAngle : REAL := 0.0;
END_VAR

VAR
    SunriseTime : TIME := T#6H;
    SunsetTime : TIME := T#18H;
    NoonTime : TIME := T#12H;
    MorningAngle : REAL := 30.0;
    NoonAngle : REAL := 60.0;
    EveningAngle : REAL := 30.0;
    state : INT := 0;
    prevState : INT := -1;
END_VAR

CASE state OF
    0: (* STATE 0: INITIALIZE *)
        PanelAngle := 0.0;
        state := 1;
    
    1: (* STATE 1: NIGHTTIME / OUTSIDE_SUN_HOURS *)
        PanelAngle := 0.0;
        
        IF (CurrentTime >= SunriseTime) AND (CurrentTime < NoonTime) THEN
            state := 2;
        ELSIF (CurrentTime >= NoonTime) AND (CurrentTime < SunsetTime) THEN
            IF SolarIntensity >= 90.0 THEN
                state := 3;
            ELSE
                state := 4;
            END_IF;
        END_IF;
    
    2: (* STATE 2: MORNING_ANGLE *)
        PanelAngle := MorningAngle;
        
        IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
            state := 1;
        ELSIF (CurrentTime >= NoonTime) THEN
            IF SolarIntensity >= 90.0 THEN
                state := 3;
            ELSE
                state := 4;
            END_IF;
        END_IF;
    
    3: (* STATE 3: NOON_ANGLE_HIGH_INTENSITY *)
        PanelAngle := NoonAngle;
        
        IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
            state := 1;
        ELSIF CurrentTime < NoonTime THEN
            state := 2;
        ELSIF (CurrentTime >= NoonTime) AND (SolarIntensity < 90.0) THEN
            state := 4;
        END_IF;
    
    4: (* STATE 4: EVENING_ANGLE *)
        PanelAngle := EveningAngle;
        
        IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
            state := 1;
        ELSIF CurrentTime < NoonTime THEN
            state := 2;
        ELSIF (CurrentTime >= NoonTime) AND (SolarIntensity >= 90.0) THEN
            state := 3;
        END_IF;
END_CASE;

(* Clamp PanelAngle between 0.0 and 90.0 degrees *)
IF PanelAngle < 0.0 THEN
    PanelAngle := 0.0;
ELSIF PanelAngle > 90.0 THEN
    PanelAngle := 90.0;
END_IF;

END_FUNCTION_BLOCK
END_ST