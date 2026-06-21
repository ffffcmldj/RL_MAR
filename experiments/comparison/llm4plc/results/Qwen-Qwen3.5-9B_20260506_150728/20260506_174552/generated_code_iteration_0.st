START_ST
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
    CurrentTime : TIME;
    SolarIntensity : REAL;
END_VAR
VAR
    state : INT; (* The FSM state variable (0=Night, 1=Morning, 2=Evening, 3=Override) *)
    prevState : INT; (* To track previous state if needed for complex logic *)
    currentAngle : REAL; (* Temporary variable to hold the calculated angle before assignment to output *)
END_VAR

(* Initialize state if this is the first execution or reset logic *)
IF NOT (CurrentTime > T#0) OR (CurrentTime < T#0) THEN
    state := 0;
ELSE
    (* Determine current state based on logic plan *)
    (* STATE 3: HIGH_INTENSITY_OVERRIDE_MODE takes precedence *)
    IF SolarIntensity >= 90.0 THEN
        state := 3;
    (* STATE 0: NIGHT_MODE *)
    ELSIF (CurrentTime < SunriseTime) OR (CurrentTime >= SunsetTime) THEN
        state := 0;
    (* STATE 1: MORNING_MODE *)
    ELSIF CurrentTime < NoonTime THEN
        state := 1;
    (* STATE 2: EVENING_MODE *)
    ELSE
        state := 2;
    END_IF;
END_IF;

(* Assign output based on the determined state *)
CASE state OF
    0: (* NIGHT_MODE *)
        currentAngle := 0.0;
    1: (* MORNING_MODE *)
        currentAngle := MorningAngle;
    2: (* EVENING_MODE *)
        currentAngle := EveningAngle;
    3: (* HIGH_INTENSITY_OVERRIDE_MODE *)
        currentAngle := NoonAngle;
    ELSE
        currentAngle := 0.0; (* Default safety value *)
END_CASE;

(* Update the output variable *)
PanelAngle := currentAngle;

END_FUNCTION_BLOCK
END_ST