FUNCTION_BLOCK SolarPanelTracking
    VAR
        PanelAngle : REAL; (* Output for adjusting the solar panel angle *)
        SunriseTime : TIME := T#6H; (* Set the time for sunrise (6:00 AM) *)
        SunsetTime : TIME := T#18H; (* Set the time for sunset (6:00 PM) *)
        NoonTime : TIME := T#12H; (* Set the time for solar noon (12:00 PM) *)
        MorningAngle : REAL := 30.0; (* Set the morning angle for panels *)
        NoonAngle : REAL := 60.0; (* Set the noon angle for panels *)
        EveningAngle : REAL := 30.0; (* Set the evening angle for panels *)
    END_VAR
    VAR_INPUT
        CurrentTime : TIME; (* Input for current time from PLC's real-time clock *)
        SolarIntensity : REAL; (* Input for measured solar intensity *)
    END_VAR

    (* Control Logic Execution *)
    IF SolarIntensity >= 90.0 THEN
        (* High Solar Intensity Override State *)
        PanelAngle := NoonAngle;
    ELSE
        (* Time-Based Tracking *)
        IF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
            (* Nighttime State *)
            PanelAngle := 0.0;
        ELSIF (CurrentTime >= SunriseTime) AND (CurrentTime < NoonTime) THEN
            (* Morning State *)
            PanelAngle := MorningAngle;
        ELSIF (CurrentTime >= NoonTime) AND (CurrentTime < SunsetTime) THEN
            (* Afternoon/Evening State *)
            PanelAngle := EveningAngle;
        END_IF
    END_IF
END_FUNCTION_BLOCK