FUNCTION_BLOCK HomeBrewingSystem
VAR_INPUT
    TemperatureSensor : REAL;      (* Current temperature in °C *)
    WaterFlowSensor : REAL;        (* Current water flow in L/min *)
    BrewingStartTime : TIME;       (* Start time of brewing process *)
    BrewingDuration : TIME;        (* Total duration of brewing process *)
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL;         (* Control signal for heating element *)
    AgitationMotor : BOOL;         (* Control signal for agitation motor *)
    HopsDispenser : BOOL;          (* Control signal for hops dispenser *)
    FermentationTank : BOOL;       (* Control signal for fermentation tank transfer *)
END_VAR
VAR
    CurrentTime : TIME;            (* Current system time *)
    ElapsedTime : TIME;            (* Time elapsed since brewing start *)
    ProcessActive : BOOL;          (* Flag indicating if brewing process is active *)
END_VAR

(* Calculate current time and elapsed brewing time *)
CurrentTime := TIME();
ElapsedTime := CurrentTime - BrewingStartTime;

(* Determine if brewing process is within scheduled duration *)
ProcessActive := (ElapsedTime >= T#0s) AND (ElapsedTime <= BrewingDuration);

(* Temperature control: Maintain 65°C *)
IF TemperatureSensor < 65.0 THEN
    HeatingElement := TRUE;
ELSE
    HeatingElement := FALSE;
END_IF;

(* Agitation motor control based on water flow *)
IF WaterFlowSensor > 0.5 THEN
    AgitationMotor := TRUE;
ELSE
    AgitationMotor := FALSE;
END_IF;

(* Hops dispensing after 5 hours, only during active brewing process *)
IF ProcessActive AND (ElapsedTime >= T#5h) THEN
    HopsDispenser := TRUE;
ELSE
    HopsDispenser := FALSE;
END_IF;

(* Fermentation tank transfer after 48 hours, only during active brewing process *)
IF ProcessActive AND (ElapsedTime >= T#48h) THEN
    FermentationTank := TRUE;
ELSE
    FermentationTank := FALSE;
END_IF;

END_FUNCTION_BLOCK