START_REASON
The validation feedback indicates a syntax error in the CODESYS compiler: "发现非预期的记号'END_VAR'" (Unexpected token 'END_VAR').

Analyzing the provided code:
1.  The code starts with `START_ST` and `END_ST`.
2.  Inside the `FUNCTION_BLOCK`, there is a `VAR` section.
3.  After the `VAR` section, the code immediately places `END_VAR`.
4.  However, in IEC 61131-3 Structured Text (ST), the `VAR` section must be closed with `END_VAR`, but the `FUNCTION_BLOCK` body itself must be closed with `END_FUNCTION_BLOCK`.
5.  Looking closely at the provided code structure:
    ```st
    VAR
        ...
    END_VAR  <-- This closes the VAR section correctly.

    BEGIN
        ...
    END_FUNCTION_BLOCK  <-- This closes the function block.
    ```
    Wait, let me re-examine the provided code in the prompt.
    The provided code has:
    ```st
    END_VAR

    BEGIN
        ...
    END_FUNCTION_BLOCK
    END_ST
    ```
    Actually, looking at the raw input provided in the prompt:
    ```st
    VAR
        CurrentState : INT := 0;
        ...
    END_VAR

    END_VAR  <--- HERE IS THE ERROR
    BEGIN
        ...
    END_FUNCTION_BLOCK
    ```
    The code contains **two** `END_VAR` statements. The first one correctly closes the `VAR` section. The second one, placed before `BEGIN`, is invalid because there is no `VAR` section open to close at that point (the `VAR` section was already closed). The compiler sees `END_VAR` where it expects the start of the `BEGIN` block or other valid statements, hence the "Unexpected token" error.

    Correction Plan:
    1.  Remove the duplicate `END_VAR` that appears before `BEGIN`.
    2.  Ensure the structure follows: `FUNCTION_BLOCK` -> `VAR_INPUT` -> `VAR_OUTPUT` -> `VAR` -> `END_VAR` -> `BEGIN` -> `END_FUNCTION_BLOCK`.
    3.  Keep the `START_ST` and `END_ST` markers as requested.
    4.  Maintain the `FUNCTION_BLOCK` structure.
    5.  Ensure all variable sections use `END_VAR` correctly.

The logic inside the function block (State Machine) seems logically sound for a basic tracking system, though the transitions could be optimized, the immediate task is to fix the syntax error reported by the toolchain.
END_REASON

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