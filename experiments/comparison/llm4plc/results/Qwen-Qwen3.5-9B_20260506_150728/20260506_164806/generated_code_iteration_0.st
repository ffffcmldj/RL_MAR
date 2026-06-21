START_ST
FUNCTION_BLOCK SolarPanelTracking
VAR_INPUT
    SolarIntensity : REAL;      (* Input: Solar intensity in percentage *)
    CurrentTime : TIME;         (* Input: Current time of day *)
END_VAR

VAR_OUTPUT
    PanelAngle : REAL := 0.0;   (* Output: Panel angle in degrees *)
END_VAR

VAR
    CurrentState : INT := 0;    (* Tracks the current FSM state: 0=Night, 1=Morning, 2=Noon, 3=Evening *)
    SunriseTime : TIME := T#6H;    (* Sunrise time set to 6 AM *)
    SunsetTime : TIME := T#18H;     (* Sunset time set to 6 PM *)
    NoonTime : TIME := T#12H;       (* Noon time set to 12 PM *)
    MorningAngle : REAL := 30.0;     (* Angle during morning *)
    NoonAngle : REAL := 60.0;        (* Angle during noon *)
    EveningAngle : REAL := 30.0;      (* Angle during evening *)
END_VAR

END_VAR

BEGIN
    (* --- STATE MACHINE LOGIC --- *)

    (* Transition: Night (0) -> Morning (1) *)
    (* Condition: Time is between Sunrise and Noon *)
    IF (CurrentTime >= SunriseTime) AND (CurrentTime < NoonTime) THEN
        CurrentState := 1;
    END_IF;

    (* Transition: Morning (1) -> Noon (2) *)
    (* Condition: Time is >= Noon AND Solar Intensity >= 90% *)
    IF (CurrentState = 1) AND (CurrentTime >= NoonTime) AND (SolarIntensity >= 90.0) THEN
        CurrentState := 2;
    END_IF;

    (* Transition: Morning (1) -> Evening (3) *)
    (* Condition: Time is >= Noon AND Solar Intensity < 90% *)
    IF (CurrentState = 1) AND (CurrentTime >= NoonTime) AND (SolarIntensity < 90.0) THEN
        CurrentState := 3;
    END_IF;

    (* Transition: Noon (2) -> Night (0) *)
    (* Condition: Time is >= Sunset *)
    IF (CurrentState = 2) AND (CurrentTime >= SunsetTime) THEN
        CurrentState := 0;
    END_IF;

    (* Transition: Evening (3) -> Night (0) *)
    (* Condition: Time is >= Sunset *)
    IF (CurrentState = 3) AND (CurrentTime >= SunsetTime) THEN
        CurrentState := 0;
    END_IF;

    (* Transition: Noon (2) -> Morning (1) *)
    (* Back transition if time wraps or logic resets before sunset *)
    IF (CurrentState = 2) AND (CurrentTime < NoonTime) THEN
        CurrentState := 1;
    END_IF;

    (* Transition: Evening (3) -> Morning (1) *)
    (* Back transition if time wraps or logic resets before sunset *)
    IF (CurrentState = 3) AND (CurrentTime < NoonTime) THEN
        CurrentState := 1;
    END_IF;

    (* --- OUTPUT ASSIGNMENT --- *)
    (* Assign angle based on the determined state *)
    CASE CurrentState OF
        0: PanelAngle := 0.0;
        1: PanelAngle := MorningAngle;
        2: PanelAngle := NoonAngle;
        3: PanelAngle := EveningAngle;
    END_CASE;

    (* --- SAFETY CLAMP --- *)
    (* Ensure angle is strictly between 0.0 and 90.0 degrees *)
    IF PanelAngle > 90.0 THEN
        PanelAngle := 90.0;
    ELSIF PanelAngle < 0.0 THEN
        PanelAngle := 0.0;
    END_IF;

END_FUNCTION_BLOCK
END_ST