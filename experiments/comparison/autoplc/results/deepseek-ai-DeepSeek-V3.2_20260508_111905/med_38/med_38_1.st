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
    SunsetTime : TIME := T#18H;     (* Sunset time set to 6 PM *)
    NoonTime : TIME := T#12H;       (* Noon time set to 12 PM *)
    MorningAngle : REAL := 30.0;     (* Angle during morning *)
    NoonAngle : REAL := 60.0;        (* Angle during noon *)
    EveningAngle : REAL := 30.0;      (* Angle during evening *)
END_VAR

VAR
    tempAngle : REAL;  (* Temporary variable for angle calculation *)
END_VAR

(* Main execution logic *)
(* Check if current time is outside sunrise to sunset range (nighttime) *)
IF (CurrentTime < SunriseTime) OR (CurrentTime > SunsetTime) THEN
    PanelAngle := 0.0;  (* Set panel angle to zero during nighttime *)
ELSE
    (* Daylight operation *)
    IF SolarIntensity >= 90.0 THEN
        tempAngle := NoonAngle;  (* High intensity override *)
    ELSE
        (* Time-based angle selection *)
        IF CurrentTime < NoonTime THEN
            tempAngle := MorningAngle;  (* Morning angle before noon *)
        ELSE
            tempAngle := EveningAngle;  (* Evening angle after noon *)
        END_IF
    END_IF
    
    (* Apply angle boundary constraints *)
    IF tempAngle < 0.0 THEN
        PanelAngle := 0.0;
    ELSIF tempAngle > 90.0 THEN
        PanelAngle := 90.0;
    ELSE
        PanelAngle := tempAngle;
    END_IF
END_IF

END_FUNCTION_BLOCK