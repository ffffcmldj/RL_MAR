ructured-text
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
    state : INT; (* The state variable *)
    prevState : INT; (* The previous state variable *)
    brewingDurationInHours : INT; (* The brewing duration in hours *)
    temperature : REAL; (* The temperature variable *)
    waterFlow : REAL; (* The water flow variable *)
END_VAR

(* Initialize variables *)
state := 0;
prevState := 0;

(* Calculate brewing duration in hours *)
brewingDurationInHours := TO_INT(BrewingDuration / T#1h);

(* Control Logic *)
CASE state OF
    0: (* STATE 0: INITIALIZE *)
        HeatingElement := FALSE;
        AgitationMotor := FALSE;
        HopsDispenser := FALSE;
        FermentationTank := FALSE;
        state := 1; (* Transition to STATE 1 *)

    1: (* STATE 1: HEATING CONTROL *)
        IF TemperatureSensor < 65.0 THEN
            HeatingElement := TRUE;
        ELSE
            HeatingElement := FALSE;
        END_IF;
        state := 1; (* Remain in STATE 1 *)

    2: (* STATE 2: AGITATION CONTROL *)
        IF WaterFlowSensor > 0.5 THEN
            AgitationMotor := TRUE;
        ELSE
            AgitationMotor := FALSE;
        END_IF;
        state := 2; (* Remain in STATE 2 *)

    3: (* STATE 3: HOPS DISPENSING CONTROL *)
        IF brewingDurationInHours >= 5 THEN
            HopsDispenser := TRUE;
        ELSE
            HopsDispenser := FALSE;
        END_IF;
        state := 3; (* Remain in STATE 3 *)

    4: (* STATE 4: FERMENTATION CONTROL *)
        IF brewingDurationInHours >= 48 THEN
            FermentationTank := TRUE;
        ELSE
            FermentationTank := FALSE;
        END_IF;
        state := 4; (* Remain in STATE 4 *)

END_CASE;

END_FUNCTION_BLOCK