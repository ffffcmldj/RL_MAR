START_ST
FUNCTION_BLOCK GreenhouseWateringSystem
VAR_INPUT
    SoilMoistureSensor : REAL;
    ResponseDelay : TIME := T#5s;
END_VAR
VAR_OUTPUT
    SprinklersOn : BOOL;
END_VAR
VAR
    state : INT := 0;
    prevState : INT := -1;
    LastMoistureReading : REAL := 0.0;
    delayTimer : TON;
    inDelay : BOOL := FALSE;
    targetState : INT := 0;
END_VAR

(* State machine execution *)
(* Update last moisture reading for tracking *)
LastMoistureReading := SoilMoistureSensor;

(* Check if we are currently in a delay period *)
IF inDelay THEN
    delayTimer(IN:=TRUE, PT:=ResponseDelay);
    IF delayTimer.Q THEN
        (* Delay period finished, perform the state transition *)
        state := targetState;
        inDelay := FALSE;
        delayTimer(IN:=FALSE);
    END_IF;
ELSE
    (* No active delay, evaluate transitions immediately *)
    CASE state OF
        0: (* STATE 0: INITIALIZE (IDLE) *)
            SprinklersOn := FALSE;
            IF SoilMoistureSensor < 30.0 THEN
                targetState := 1;
                inDelay := TRUE;
                delayTimer(IN:=TRUE, PT:=ResponseDelay);
            ELSIF SoilMoistureSensor >= 30.0 THEN
                targetState := 2;
                inDelay := TRUE;
                delayTimer(IN:=TRUE, PT:=ResponseDelay);
            END_IF;

        1: (* STATE 1: SPRINKLERS ON (WATERING) *)
            SprinklersOn := TRUE;
            IF SoilMoistureSensor >= 70.0 THEN
                targetState := 2;
                inDelay := TRUE;
                delayTimer(IN:=TRUE, PT:=ResponseDelay);
            END_IF;
            (* Remain in state 1 if SoilMoistureSensor < 70.0 *)

        2: (* STATE 2: SPRINKLERS OFF (NOT WATERING) *)
            SprinklersOn := FALSE;
            IF SoilMoistureSensor < 30.0 THEN
                targetState := 1;
                inDelay := TRUE;
                delayTimer(IN:=TRUE, PT:=ResponseDelay);
            END_IF;
            (* Remain in state 2 if SoilMoistureSensor >= 30.0 *)

    END_CASE;
END_IF;

(* Update previous state for tracking *)
prevState := state;

END_FUNCTION_BLOCK
END_ST