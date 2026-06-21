FUNCTION_BLOCK HomeBrewingSystem
VAR_INPUT
    TemperatureSensor : REAL;     (* Current temperature measurement in °C *)
    WaterFlowSensor : REAL;       (* Current water flow measurement in units *)
    BrewingStartTime : TIME;      (* Absolute time when brewing started *)
    BrewingDuration : TIME;       (* Total duration of the brewing process *)
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL;        (* Control signal for heating element *)
    AgitationMotor : BOOL;        (* Control signal for agitation motor *)
    HopsDispenser : BOOL;         (* Control signal for hops dispenser *)
    FermentationTank : BOOL;      (* Control signal for fermentation tank *)
END_VAR
VAR
    CurrentTime : TIME;           (* Current system time *)
    ElapsedBrewingTime : TIME;    (* Time elapsed since brewing started *)
END_VAR

(* Calculate elapsed time since brewing started *)
CurrentTime := TIME();
ElapsedBrewingTime := CurrentTime - BrewingStartTime;

(* Control heating element based on temperature *)
IF TemperatureSensor < 65.0 THEN
    HeatingElement := TRUE;
ELSE
    HeatingElement := FALSE;
END_IF;

(* Control agitation motor based on water flow *)
IF WaterFlowSensor > 0.5 THEN
    AgitationMotor := TRUE;
ELSE
    AgitationMotor := FALSE;
END_IF;

(* Control hops dispenser - activate after 5 hours of brewing *)
IF ElapsedBrewingTime >= T#5h AND ElapsedBrewingTime <= BrewingDuration THEN
    HopsDispenser := TRUE;
ELSE
    HopsDispenser := FALSE;
END_IF;

(* Control fermentation tank - activate after 48 hours of brewing *)
IF ElapsedBrewingTime >= T#48h AND ElapsedBrewingTime <= BrewingDuration THEN
    FermentationTank := TRUE;
ELSE
    FermentationTank := FALSE;
END_IF;

END_FUNCTION_BLOCK