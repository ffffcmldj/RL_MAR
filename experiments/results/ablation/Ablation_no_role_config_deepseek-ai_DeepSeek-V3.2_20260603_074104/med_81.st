FUNCTION_BLOCK SolarPanelTracking
VAR_INPUT
    CurrentTime : TIME;
    SolarIntensity : REAL;
END_VAR

VAR_OUTPUT
    PanelAngle : REAL;
END_VAR

VAR
    SunriseTime : TIME := T#6H;
    NoonTime : TIME := T#12H;
    SunsetTime : TIME := T#18H;
    MorningAngle : REAL := 30.0;
    NoonAngle : REAL := 60.0;
    EveningAngle : REAL := 30.0;
END_VAR

// Main logic
IF SolarIntensity >= 90.0 THEN
    // Solar intensity override - highest priority
    PanelAngle := NoonAngle;
ELSE
    // Time-based tracking
    IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
        // Nighttime
        PanelAngle := 0.0;
    ELSIF (CurrentTime >= SunriseTime) AND (CurrentTime < NoonTime) THEN
        // Morning period
        PanelAngle := MorningAngle;
    ELSIF (CurrentTime >= NoonTime) AND (CurrentTime < SunsetTime) THEN
        // Afternoon/Evening period
        PanelAngle := EveningAngle;
    ELSE
        // Fallback (should not occur with proper time ranges)
        PanelAngle := 0.0;
    END_IF;
END_IF;

END_FUNCTION_BLOCK