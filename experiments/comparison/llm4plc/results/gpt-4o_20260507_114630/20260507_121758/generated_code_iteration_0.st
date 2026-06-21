plaintext
START_ST
FUNCTION_BLOCK SolarPanelTracking
VAR_INPUT
    CurrentTime : TIME; (* The current time from the PLC's real-time clock *)
    SolarIntensity : REAL; (* The measured solar intensity *)
END_VAR

VAR_OUTPUT
    PanelAngle : REAL; (* The output for adjusting the solar panel angle *)
END_VAR

VAR
    SunriseTime : TIME := T#6H; (* The time for sunrise (6:00 AM) *)
    NoonTime : TIME := T#12H; (* The time for solar noon (12:00 PM) *)
    SunsetTime : TIME := T#18H; (* The time for sunset (6:00 PM) *)
    MorningAngle : REAL := 30.0; (* The morning angle for the solar panel *)
    NoonAngle : REAL := 60.0; (* The noon angle for the solar panel *)
    EveningAngle : REAL := 30.0; (* The evening angle for the solar panel *)
    state : INT := 0; (* The current state of the FSM, initialized to NIGHTTIME *)
    prevState : INT := 0; (* The previous state of the FSM *)
END_VAR

(* FSM Logic *)
IF SolarIntensity >= 90.0 THEN
    (* Transition to STATE 3: SOLAR INTENSITY OVERRIDE *)
    prevState := state; (* Save the current state before overriding *)
    state := 3;
ELSIF state = 3 AND SolarIntensity < 90.0 THEN
    (* Return to the previous state based on CurrentTime *)
    state := prevState;
END_IF

CASE state OF
    0: (* STATE 0: NIGHTTIME *)
        PanelAngle := 0.0; (* Set panel angle to horizontal *)
        (* Transition logic for NIGHTTIME *)
        IF CurrentTime >= SunriseTime AND CurrentTime < NoonTime AND SolarIntensity < 90.0 THEN
            state := 1; (* Transition to STATE 1: MORNING *)
        END_IF;

    1: (* STATE 1: MORNING *)
        PanelAngle := MorningAngle; (* Set panel angle to MorningAngle *)
        (* Transition logic for MORNING *)
        IF CurrentTime >= NoonTime AND CurrentTime < SunsetTime AND SolarIntensity < 90.0 THEN
            state := 2; (* Transition to STATE 2: AFTERNOON/EVENING *)
        END_IF;

    2: (* STATE 2: AFTERNOON/EVENING *)
        PanelAngle := EveningAngle; (* Set panel angle to EveningAngle *)
        (* Transition logic for AFTERNOON/EVENING *)
        IF (CurrentTime >= SunsetTime OR CurrentTime < SunriseTime) AND SolarIntensity < 90.0 THEN
            state := 0; (* Transition to STATE 0: NIGHTTIME *)
        END_IF;

    3: (* STATE 3: SOLAR INTENSITY OVERRIDE *)
        PanelAngle := NoonAngle; (* Set panel angle to NoonAngle *)
        (* No additional transition logic here as state transitions are handled above *)
END_CASE;
END_FUNCTION_BLOCK
END_ST