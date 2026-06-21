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
    CurrentTime : TIME;
    ElapsedBrewingTime : TIME;
END_VAR

(* Calculate elapsed brewing time *)
CurrentTime := TIME(); (* Get current PLC time *)
IF BrewingStartTime <= CurrentTime THEN
    ElapsedBrewingTime := CurrentTime - BrewingStartTime;
ELSE
    ElapsedBrewingTime := T#0s; (* Handle invalid start time *)
END_IF

(* Control Heating Element based on temperature *)
IF TemperatureSensor < 65.0 THEN
    HeatingElement := TRUE;
ELSE
    HeatingElement := FALSE;
END_IF;

(* Control Agitation Motor based on water flow *)
IF WaterFlowSensor > 0.5 THEN
    AgitationMotor := TRUE;
ELSE
    AgitationMotor := FALSE;
END_IF;

(* Control Hops Dispenser after 5 hours of brewing *)
IF (ElapsedBrewingTime >= T#5h) AND (ElapsedBrewingTime <= BrewingDuration) THEN
    HopsDispenser := TRUE;
ELSE
    HopsDispenser := FALSE;
END_IF;

(* Control Fermentation Tank after 48 hours of brewing *)
IF (ElapsedBrewingTime >= T#48h) AND (ElapsedBrewingTime <= BrewingDuration) THEN
    FermentationTank := TRUE;
ELSE
    FermentationTank := FALSE;
END_IF;

END_FUNCTION_BLOCK