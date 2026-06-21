plaintext
START_ST
FUNCTION_BLOCK HomeBrewingSystem
VAR_INPUT
    TemperatureSensor : REAL; (* Input for temperature measurement *)
    WaterFlowSensor : REAL; (* Input for water flow measurement *)
    BrewingStartTime : TIME; (* Input for brewing start time *)
    BrewingDuration : TIME; (* Input for brewing duration *)
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL; (* Output for heating element *)
    AgitationMotor : BOOL; (* Output for agitation motor *)
    HopsDispenser : BOOL; (* Output for hops dispenser *)
    FermentationTank : BOOL; (* Output for fermentation tank *)
END_VAR
VAR
    state : INT; (* Current state of the FSM *)
    BrewingElapsedTime : TIME; (* Tracks the elapsed brewing time *)
    CurrentTime : TIME; (* Current time in the system *)
END_VAR

(* Initialize outputs and variables *)
IF state = 0 THEN
    HeatingElement := FALSE;
    AgitationMotor := FALSE;
    HopsDispenser := FALSE;
    FermentationTank := FALSE;
    BrewingElapsedTime := T#0S;

    (* Transition to STATE 1 if BrewingStartTime is reached *)
    IF BrewingStartTime <= CurrentTime THEN
        state := 1;
    END_IF;

ELSIF state = 1 THEN
    (* Heating logic *)
    IF TemperatureSensor < 65.0 THEN
        HeatingElement := TRUE;
    ELSE
        HeatingElement := FALSE;
    END_IF;

    (* Transition to STATE 2 *)
    state := 2;

ELSIF state = 2 THEN
    (* Agitation logic *)
    IF WaterFlowSensor > 0.5 THEN
        AgitationMotor := TRUE;
    ELSE
        AgitationMotor := FALSE;
    END_IF;

    (* Update BrewingElapsedTime *)
    BrewingElapsedTime := CurrentTime - BrewingStartTime;

    (* Transition to STATE 3 if BrewingDuration >= 5 hours *)
    IF BrewingElapsedTime >= T#5H THEN
        state := 3;
    END_IF;

ELSIF state = 3 THEN
    (* Hops dispensing logic *)
    IF BrewingElapsedTime >= T#5H THEN
        HopsDispenser := TRUE;
    ELSE
        HopsDispenser := FALSE;
    END_IF;

    (* Transition to STATE 4 if BrewingDuration >= 48 hours *)
    IF BrewingElapsedTime >= T#48H THEN
        state := 4;
    END_IF;

ELSIF state = 4 THEN
    (* Fermentation logic *)
    IF BrewingElapsedTime >= T#48H THEN
        FermentationTank := TRUE;
    ELSE
        FermentationTank := FALSE;
    END_IF;

    (* Transition to STATE 0 if brewing process is complete *)
    IF BrewingElapsedTime >= BrewingDuration THEN
        state := 0;
    END_IF;

END_IF;

END_FUNCTION_BLOCK
END_ST