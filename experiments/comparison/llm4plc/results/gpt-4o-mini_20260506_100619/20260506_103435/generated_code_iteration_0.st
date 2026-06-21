ructured-text
START_ST
FUNCTION_BLOCK HomeBrewingSystem
VAR_INPUT
    TemperatureSensor : REAL; (* Input for temperature measurement (°C) *)
    WaterFlowSensor : REAL; (* Input for water flow measurement (L/min) *)
    BrewingStartTime : TIME; (* Input for brewing process start time *)
    BrewingDuration : TIME; (* Input for total brewing duration *)
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL; (* Output to control heating element *)
    AgitationMotor : BOOL; (* Output to control agitation motor *)
    HopsDispenser : BOOL; (* Output to control hops dispenser *)
    FermentationTank : BOOL; (* Output to control fermentation tank *)
END_VAR
VAR
    state : INT; (* THE STATE VARIABLE *)
    prevState : INT; (* THE PREVIOUS STATE VARIABLE *)
    currentTime : TIME; (* THE CURRENT TIME VARIABLE *)
    elapsedTime : TIME; (* THE ELAPSED TIME VARIABLE *)
END_VAR

(* Initialize state *)
state := 0;
HeatingElement := FALSE;
AgitationMotor := FALSE;
HopsDispenser := FALSE;
FermentationTank := FALSE;

(* Main control loop *)
WHILE TRUE DO
    currentTime := TIME(); (* Get the current time *)

    CASE state OF
        0: (* STATE 0: INITIALIZE *)
            HeatingElement := FALSE;
            AgitationMotor := FALSE;
            HopsDispenser := FALSE;
            FermentationTank := FALSE;
            IF TemperatureSensor < 65.0 THEN
                state := 1; (* Transition to STATE 1 *)
            END_IF;

        1: (* STATE 1: HEATING TO 65 DEGREES *)
            HeatingElement := TRUE;
            AgitationMotor := FALSE;
            HopsDispenser := FALSE;
            FermentationTank := FALSE;
            IF TemperatureSensor >= 65.0 THEN
                state := 2; (* Transition to STATE 2 *)
            END_IF;

        2: (* STATE 2: MAINTAIN TEMPERATURE *)
            HeatingElement := FALSE;
            AgitationMotor := (WaterFlowSensor > 0.5);
            HopsDispenser := FALSE;
            FermentationTank := FALSE;
            IF (currentTime - BrewingStartTime) >= (BrewingDuration + TIME#5h) THEN
                state := 4; (* Transition to STATE 4 *)
            ELSIF (WaterFlowSensor <= 0.5) THEN
                state := 3; (* Transition to STATE 3 *)
            END_IF;

        3: (* STATE 3: AGITATING *)
            HeatingElement := FALSE;
            AgitationMotor := TRUE;
            HopsDispenser := FALSE;
            FermentationTank := FALSE;
            IF (WaterFlowSensor <= 0.5) THEN
                state := 2; (* Transition back to STATE 2 *)
            END_IF;

        4: (* STATE 4: DISPENSING HOPS *)
            HeatingElement := FALSE;
            AgitationMotor := FALSE;
            HopsDispenser := TRUE;
            FermentationTank := FALSE;
            IF (currentTime - BrewingStartTime) >= (BrewingDuration + TIME#48h) THEN
                state := 5; (* Transition to STATE 5 *)
            END_IF;

        5: (* STATE 5: TRANSFERRING TO FERMENTATION TANK *)
            HeatingElement := FALSE;
            AgitationMotor := FALSE;
            HopsDispenser := FALSE;
            FermentationTank := TRUE;
    END_CASE;

    prevState := state; (* Update previous state *)
END_WHILE;

END_FUNCTION_BLOCK
END_ST