plaintext
START_ST
FUNCTION_BLOCK HomeBrewingSystem
VAR_INPUT
    TemperatureSensor : REAL; (* Input for temperature measurement (°C) *)
    WaterFlowSensor : REAL; (* Input for water flow measurement (L/min) *)
    BrewingStartTime : TIME; (* Input for brewing process start time *)
    BrewingDuration : TIME; (* Input for total brewing duration *)
    CurrentTime : TIME; (* Input for the current time in the system *)
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL; (* Output to control heating element *)
    AgitationMotor : BOOL; (* Output to control agitation motor *)
    HopsDispenser : BOOL; (* Output to control hops dispenser *)
    FermentationTank : BOOL; (* Output to control fermentation tank *)
END_VAR
VAR
    state : INT := 0; (* Current state of the system *)
    prevState : INT := -1; (* Previous state of the system *)
    BrewingTime : TIME; (* Elapsed brewing time, calculated as CurrentTime - BrewingStartTime *)
    HopsDispensed : BOOL := FALSE; (* Flag to track if hops have been dispensed *)
    FermentationStarted : BOOL := FALSE; (* Flag to track if fermentation transfer has started *)
END_VAR

(* Calculate the elapsed brewing time *)
BrewingTime := CurrentTime - BrewingStartTime;

(* State machine implementation *)
CASE state OF
    0: (* STATE 0: INITIALIZE *)
        (* Initialize all outputs to OFF *)
        HeatingElement := FALSE;
        AgitationMotor := FALSE;
        HopsDispenser := FALSE;
        FermentationTank := FALSE;

        (* Transition to STATE 1 *)
        state := 1;

    1: (* STATE 1: MAINTAIN_TEMPERATURE *)
        (* Control the heating element based on the temperature sensor *)
        IF TemperatureSensor < 65.0 THEN
            HeatingElement := TRUE;
        ELSE
            HeatingElement := FALSE;
        END_IF;

        (* Transition to STATE 2 (runs concurrently with STATE 1) *)
        state := 2;

    2: (* STATE 2: CONTROL_AGITATION *)
        (* Control the agitation motor based on the water flow sensor *)
        IF WaterFlowSensor > 0.5 THEN
            AgitationMotor := TRUE;
        ELSE
            AgitationMotor := FALSE;
        END_IF;

        (* Check if it's time to dispense hops (5 hours elapsed) *)
        IF BrewingTime >= T#5H AND NOT HopsDispensed THEN
            state := 3;
        END_IF;

    3: (* STATE 3: DISPENSE_HOPS *)
        (* Dispense hops for one cycle *)
        HopsDispenser := TRUE;
        HopsDispensed := TRUE;

        (* Turn off the hops dispenser after one cycle *)
        HopsDispenser := FALSE;

        (* Check if it's time to transfer to fermentation (48 hours elapsed) *)
        IF BrewingTime >= T#48H AND NOT FermentationStarted THEN
            state := 4;
        ELSE
            (* Return to STATE 2 to continue monitoring agitation *)
            state := 2;
        END_IF;

    4: (* STATE 4: TRANSFER_TO_FERMENTATION *)
        (* Transfer to fermentation tank for one cycle *)
        FermentationTank := TRUE;
        FermentationStarted := TRUE;

        (* Turn off the fermentation tank transfer after one cycle *)
        FermentationTank := FALSE;

        (* Final state, remain here *)
        state := 4;

    ELSE
        (* Default case to handle unexpected states *)
        state := 0; (* Reset to INITIALIZE state *)
END_CASE;

END_FUNCTION_BLOCK
END_ST