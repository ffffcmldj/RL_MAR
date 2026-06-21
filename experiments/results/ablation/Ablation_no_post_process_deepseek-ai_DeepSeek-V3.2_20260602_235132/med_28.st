FUNCTION_BLOCK HomeBrewingSystem
VAR_INPUT
    TemperatureSensor : REAL;     (* Current temperature measurement in °C *)
    WaterFlowSensor : REAL;       (* Current water flow measurement in units *)
    BrewingStartTime : TIME;      (* Absolute start time of brewing process *)
    BrewingDuration : TIME;       (* Total duration of brewing process *)
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
    IsBrewingActive : BOOL;       (* Flag indicating if brewing is in progress *)
END_VAR

(* Calculate current time and elapsed brewing time *)
CurrentTime := TIME();
ElapsedBrewingTime := CurrentTime - BrewingStartTime;

(* Determine if brewing process is active *)
IsBrewingActive := (ElapsedBrewingTime >= T#0s) AND (ElapsedBrewingTime <= BrewingDuration);

(* Control heating element based on temperature *)
IF IsBrewingActive THEN
    HeatingElement := TemperatureSensor < 65.0;
ELSE
    HeatingElement := FALSE;
END_IF;

(* Control agitation motor based on water flow *)
IF IsBrewingActive THEN
    AgitationMotor := WaterFlowSensor > 0.5;
ELSE
    AgitationMotor := FALSE;
END_IF;

(* Control hops dispenser - activate after 5 hours *)
IF IsBrewingActive THEN
    HopsDispenser := ElapsedBrewingTime >= T#5h;
ELSE
    HopsDispenser := FALSE;
END_IF;

(* Control fermentation tank - activate after 48 hours *)
IF IsBrewingActive THEN
    FermentationTank := ElapsedBrewingTime >= T#48h;
ELSE
    FermentationTank := FALSE;
END_IF;

END_FUNCTION_BLOCK