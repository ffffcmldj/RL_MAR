plaintext
START_ST

FUNCTION_BLOCK GreenhouseWateringSystem
VAR_INPUT
    SoilMoistureSensor : REAL;   (* Input for soil moisture level (0-100%) *)
END_VAR

VAR_OUTPUT
    SprinklersOn : BOOL := FALSE;   (* Output for controlling sprinklers - on/off *)
END_VAR

VAR
    state : INT := 0;               (* The current state of the system *)
    prevState : INT := 0;           (* The previous state of the system *)
    ResponseDelay : TIME := T#5s;   (* Time delay to prevent rapid state transitions *)
    LastMoistureReading : REAL := 0.0; (* Stores the last soil moisture reading for comparison *)
    TimerStart : TIME := T#0s;      (* Tracks the start time of the response delay *)
    TimerElapsed : BOOL := FALSE;   (* Indicates whether the response delay has elapsed *)
    CurrentTime : TIME := T#0s;     (* Tracks the current system time *)
END_VAR

VAR_TEMP
    MoistureValid : BOOL;           (* Temporary variable to check if soil moisture is within valid range *)
END_VAR

(* Assertions to ensure system integrity *)
MoistureValid := (SoilMoistureSensor >= 0.0) AND (SoilMoistureSensor <= 100.0);
IF NOT MoistureValid THEN
    RETURN; (* Exit the function block if the soil moisture value is invalid *)
END_IF

(* Calculate if the response delay has elapsed *)
CurrentTime := TIME(); (* Get the current system time *)
IF (CurrentTime - TimerStart) >= ResponseDelay THEN
    TimerElapsed := TRUE;
ELSE
    TimerElapsed := FALSE;
END_IF

(* State machine implementation *)
CASE state OF
    0: (* STATE 0: IDLE *)
        SprinklersOn := FALSE; (* Ensure sprinklers are off *)
        IF (SoilMoistureSensor < 30.0) AND TimerElapsed THEN
            TimerStart := TIME(); (* Start the response delay timer *)
            prevState := state;
            state := 1; (* Transition to STATE 1 *)
        END_IF

    1: (* STATE 1: SPRINKLERS_ON *)
        SprinklersOn := TRUE; (* Activate sprinklers *)
        IF (SoilMoistureSensor > 70.0) AND TimerElapsed THEN
            TimerStart := TIME(); (* Start the response delay timer *)
            prevState := state;
            state := 2; (* Transition to STATE 2 *)
        END_IF

    2: (* STATE 2: SPRINKLERS_OFF *)
        SprinklersOn := FALSE; (* Deactivate sprinklers *)
        IF (SoilMoistureSensor >= 30.0) AND (SoilMoistureSensor <= 70.0) AND TimerElapsed THEN
            TimerStart := TIME(); (* Start the response delay timer *)
            prevState := state;
            state := 0; (* Transition to STATE 0 *)
        END_IF

    ELSE
        (* Default case: Reset to STATE 0 in case of an undefined state *)
        state := 0;
        SprinklersOn := FALSE;
END_CASE

END_FUNCTION_BLOCK

END_ST