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
    state : INT; (* Current state of the FSM (0-7) *)
    prevState : INT; (* Previous state for returning after hops dispensing *)
    heatingComplete : BOOL; (* Flag to track if heating target reached *)
    hopsDispensed : BOOL; (* Flag to track if hops have been dispensed *)
    fermentationStarted : BOOL; (* Flag to track if fermentation transfer started *)
    currentTime : TIME; (* Current system time *)
    elapsedTime : TIME; (* Time elapsed since brewing start *)
    hopsTime : TIME := T#5h; (* 5 hours constant for hops dispensing *)
    fermentationTime : TIME := T#48h; (* 48 hours constant for fermentation transfer *)
END_VAR

(* Main execution logic *)
currentTime := TIME(); (* Get current PLC time *)
elapsedTime := currentTime - BrewingStartTime;

CASE state OF
    0: (* STATE 0: INITIALIZE *)
        HeatingElement := FALSE;
        AgitationMotor := FALSE;
        HopsDispenser := FALSE;
        FermentationTank := FALSE;
        heatingComplete := FALSE;
        hopsDispensed := FALSE;
        fermentationStarted := FALSE;
        prevState := 1; (* Default previous state for heating *)
        state := 1; (* Immediate transition to start heating *)

    1: (* STATE 1: HEATING TO 65°C *)
        HeatingElement := TRUE;
        AgitationMotor := FALSE;
        HopsDispenser := FALSE;
        FermentationTank := FALSE;
        
        IF TemperatureSensor >= 65.0 THEN
            state := 2; (* Transition to maintaining temperature *)
            heatingComplete := TRUE;
        END_IF;
        
        (* Check for agitation based on water flow *)
        IF WaterFlowSensor > 0.5 THEN
            prevState := state;
            state := 3;
        END_IF;
        
        (* Check for hops dispensing time *)
        IF (elapsedTime >= hopsTime) AND (NOT hopsDispensed) THEN
            prevState := state;
            state := 5;
        END_IF;
        
        (* Check for fermentation transfer time *)
        IF (elapsedTime >= fermentationTime) AND (NOT fermentationStarted) THEN
            prevState := state;
            state := 6;
        END_IF;

    2: (* STATE 2: MAINTAINING TEMPERATURE (HEATING ELEMENT OFF) *)
        HeatingElement := FALSE;
        AgitationMotor := FALSE;
        HopsDispenser := FALSE;
        FermentationTank := FALSE;
        
        IF TemperatureSensor < 65.0 THEN
            state := 1; (* Transition back to heating *)
            heatingComplete := FALSE;
        END_IF;
        
        (* Check for agitation based on water flow *)
        IF WaterFlowSensor > 0.5 THEN
            prevState := state;
            state := 3;
        END_IF;
        
        (* Check for hops dispensing time *)
        IF (elapsedTime >= hopsTime) AND (NOT hopsDispensed) THEN
            prevState := state;
            state := 5;
        END_IF;
        
        (* Check for fermentation transfer time *)
        IF (elapsedTime >= fermentationTime) AND (NOT fermentationStarted) THEN
            prevState := state;
            state := 6;
        END_IF;

    3: (* STATE 3: AGITATING (MOTOR ON) *)
        HeatingElement := FALSE;
        AgitationMotor := TRUE;
        HopsDispenser := FALSE;
        FermentationTank := FALSE;
        
        IF WaterFlowSensor <= 0.5 THEN
            state := 4; (* Transition to not agitating *)
        END_IF;
        
        (* Check for hops dispensing time *)
        IF (elapsedTime >= hopsTime) AND (NOT hopsDispensed) THEN
            prevState := state;
            state := 5;
        END_IF;
        
        (* Check for fermentation transfer time *)
        IF (elapsedTime >= fermentationTime) AND (NOT fermentationStarted) THEN
            prevState := state;
            state := 6;
        END_IF;

    4: (* STATE 4: NOT AGITATING (MOTOR OFF) *)
        HeatingElement := FALSE;
        AgitationMotor := FALSE;
        HopsDispenser := FALSE;
        FermentationTank := FALSE;
        
        IF WaterFlowSensor > 0.5 THEN
            state := 3; (* Transition back to agitating *)
        END_IF;
        
        (* Check for hops dispensing time *)
        IF (elapsedTime >= hopsTime) AND (NOT hopsDispensed) THEN
            prevState := state;
            state := 5;
        END_IF;
        
        (* Check for fermentation transfer time *)
        IF (elapsedTime >= fermentationTime) AND (NOT fermentationStarted) THEN
            prevState := state;
            state := 6;
        END_IF;

    5: (* STATE 5: DISPENSING HOPS *)
        HeatingElement := FALSE;
        AgitationMotor := FALSE;
        HopsDispenser := TRUE;
        FermentationTank := FALSE;
        
        hopsDispensed := TRUE;
        state := prevState; (* Return to previous state *)

    6: (* STATE 6: TRANSFERRING TO FERMENTATION TANK *)
        HeatingElement := FALSE;
        AgitationMotor := FALSE;
        HopsDispenser := FALSE;
        FermentationTank := TRUE;
        
        fermentationStarted := TRUE;
        state := 7; (* Transition to process complete *)

    7: (* STATE 7: PROCESS COMPLETE *)
        HeatingElement := FALSE;
        AgitationMotor := FALSE;
        HopsDispenser := FALSE;
        FermentationTank := FALSE;
        (* Final state - no transitions out *)

    ELSE
        (* Error handling: reset to initial state *)
        state := 0;
END_CASE;

END_FUNCTION_BLOCK
END_ST