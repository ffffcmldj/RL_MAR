START_ST
FUNCTION_BLOCK HomeBrewingSystem
VAR_INPUT
    TemperatureSensor : REAL;
    WaterFlowSensor : REAL;
    BrewingStartTime : TIME;
    BrewingDuration : TIME;
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL;
    AgitationMotor : BOOL;
    HopsDispenser : BOOL;
    FermentationTank : BOOL;
END_VAR
VAR
    state : INT;
    prevState : INT;
    currentTime : TIME;
    elapsedTime : TIME;
END_VAR

(* State Machine Execution *)
CASE state OF
    0: (* STATE 0: INITIALIZE *)
        HeatingElement := FALSE;
        AgitationMotor := FALSE;
        HopsDispenser := FALSE;
        FermentationTank := FALSE;
        state := 1;

    1: (* STATE 1: HEATING CONTROL *)
        IF TemperatureSensor < 65.0 THEN
            HeatingElement := TRUE;
        ELSE
            HeatingElement := FALSE;
        END_IF;
        AgitationMotor := FALSE;
        HopsDispenser := FALSE;
        FermentationTank := FALSE;
        state := 2;

    2: (* STATE 2: AGITATION CONTROL *)
        IF WaterFlowSensor > 0.5 THEN
            AgitationMotor := TRUE;
        ELSE
            AgitationMotor := FALSE;
        END_IF;
        HeatingElement := FALSE;
        HopsDispenser := FALSE;
        FermentationTank := FALSE;
        state := 3;

    3: (* STATE 3: HOPS DISPENSER CONTROL *)
        IF BrewingDuration >= T#5h THEN
            HopsDispenser := TRUE;
        ELSE
            HopsDispenser := FALSE;
        END_IF;
        HeatingElement := FALSE;
        AgitationMotor := FALSE;
        FermentationTank := FALSE;
        state := 4;

    4: (* STATE 4: FERMENTATION TANK CONTROL *)
        IF BrewingDuration >= T#48h THEN
            FermentationTank := TRUE;
        ELSE
            FermentationTank := FALSE;
        END_IF;
        HeatingElement := FALSE;
        AgitationMotor := FALSE;
        HopsDispenser := FALSE;
        state := 1;

    ELSE
        state := 0;
END_CASE;

END_FUNCTION_BLOCK
END_ST