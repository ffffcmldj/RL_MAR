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
    ElapsedBrewingTime : TIME; (* Time elapsed since brewing start *)
    HopsDispensed : BOOL; (* Flag to track if hops have been dispensed *)
    TankTransferred : BOOL; (* Flag to track if transfer to fermentation tank has occurred *)
    CurrentTime : TIME; (* Current system time *)
    HopsTime : TIME := T#5h; (* Time threshold for hops dispensing *)
    FermentationTime : TIME := T#48h; (* Time threshold for fermentation transfer *)
    TargetTemperature : REAL := 65.0; (* Target brewing temperature *)
    FlowThreshold : REAL := 0.5; (* Flow threshold for agitation motor *)
END_VAR

(* Main program logic *)
CurrentTime := TIME(); (* Get current system time *)

(* Calculate elapsed brewing time *)
IF BrewingStartTime > T#0s THEN
    ElapsedBrewingTime := CurrentTime - BrewingStartTime;
    
    (* Ensure elapsed time doesn't exceed brewing duration *)
    IF ElapsedBrewingTime > BrewingDuration THEN
        ElapsedBrewingTime := BrewingDuration;
    END_IF;
ELSE
    ElapsedBrewingTime := T#0s;
END_IF;

(* Temperature control logic *)
HeatingElement := TemperatureSensor < TargetTemperature;

(* Agitation motor control logic *)
AgitationMotor := WaterFlowSensor > FlowThreshold;

(* Hops dispensing logic - activate after 5 hours, only once *)
IF (ElapsedBrewingTime >= HopsTime) AND (NOT HopsDispensed) AND (ElapsedBrewingTime <= BrewingDuration) THEN
    HopsDispenser := TRUE;
    HopsDispensed := TRUE;
ELSE
    HopsDispenser := FALSE;
END_IF;

(* Fermentation tank transfer logic - activate after 48 hours, only once *)
IF (ElapsedBrewingTime >= FermentationTime) AND (NOT TankTransferred) AND (ElapsedBrewingTime <= BrewingDuration) THEN
    FermentationTank := TRUE;
    TankTransferred := TRUE;
ELSE
    FermentationTank := FALSE;
END_IF;

(* Reset flags when brewing duration is complete or not started *)
IF (ElapsedBrewingTime >= BrewingDuration) OR (BrewingStartTime = T#0s) THEN
    HopsDispensed := FALSE;
    TankTransferred := FALSE;
END_IF;

END_FUNCTION_BLOCK