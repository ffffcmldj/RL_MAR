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
    END_VAR

    (* Control Logic *)
    IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
        (* Nighttime State: Set panel angle to zero *)
        PanelAngle := 0.0;
    ELSIF (CurrentTime >= SunriseTime) AND (CurrentTime < NoonTime) THEN
        (* Morning State *)
        IF SolarIntensity < 90.0 THEN
            PanelAngle := MorningAngle;
        ELSE
            PanelAngle := NoonAngle;
        END_IF
    ELSIF (CurrentTime >= NoonTime) AND (CurrentTime < SunsetTime) THEN
        (* Evening State *)
        IF SolarIntensity < 90.0 THEN
            PanelAngle := EveningAngle;
        ELSE
            PanelAngle := NoonAngle;
        END_IF
    END_IF

    (* Ensure PanelAngle is within 0 to 90 degrees *)
    IF PanelAngle < 0.0 THEN
        PanelAngle := 0.0;
    ELSIF PanelAngle > 90.0 THEN
        PanelAngle := 90.0;
    END_IF
END_FUNCTION_BLOCK