FUNCTION_BLOCK HomeBrewingSystem
VAR_INPUT
    TemperatureSensor : REAL;      (* Current temperature in °C *)
    WaterFlowSensor : REAL;        (* Current water flow in L/min *)
    BrewingStartTime : TIME;       (* Start time of brewing process *)
    BrewingDuration : TIME;        (* Total brewing duration *)
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL;         (* Control signal for heating element *)
    AgitationMotor : BOOL;         (* Control signal for agitation motor *)
    HopsDispenser : BOOL;          (* Control signal for hops dispenser *)
    FermentationTank : BOOL;       (* Control signal for fermentation tank transfer *)
END_VAR
VAR
    CurrentTime : TIME;            (* Current system time *)
    ElapsedBrewingTime : TIME;     (* Time elapsed since brewing start *)
    HopsDispensed : BOOL;          (* Flag to track if hops have been dispensed *)
    TankTransferred : BOOL;        (* Flag to track if transfer to fermentation tank occurred *)
END_VAR

(* Get current time *)
CurrentTime := TIME();

(* Calculate elapsed brewing time *)
ElapsedBrewingTime := CurrentTime - BrewingStartTime;

(* Temperature control logic *)
IF TemperatureSensor < 65.0 THEN
    HeatingElement := TRUE;
ELSE
    HeatingElement := FALSE;
END_IF;

(* Water flow control logic *)
IF WaterFlowSensor > 0.5 THEN
    AgitationMotor := TRUE;
ELSE
    AgitationMotor := FALSE;
END_IF;

(* Hops dispensing logic - dispense once after 5 hours *)
IF (ElapsedBrewingTime >= T#5h) AND (ElapsedBrewingTime <= BrewingDuration) AND NOT HopsDispensed THEN
    HopsDispenser := TRUE;
    HopsDispensed := TRUE;
ELSE
    HopsDispenser := FALSE;
END_IF;

(* Fermentation tank transfer logic - transfer once after 48 hours *)
IF (ElapsedBrewingTime >= T#48h) AND (ElapsedBrewingTime <= BrewingDuration) AND NOT TankTransferred THEN
    FermentationTank := TRUE;
    TankTransferred := TRUE;
ELSE
    FermentationTank := FALSE;
END_IF;

(* Reset flags when brewing duration is exceeded or before new brew starts *)
IF (ElapsedBrewingTime > BrewingDuration) OR (ElapsedBrewingTime < T#0s) THEN
    HopsDispensed := FALSE;
    TankTransferred := FALSE;
END_IF;

END_FUNCTION_BLOCK