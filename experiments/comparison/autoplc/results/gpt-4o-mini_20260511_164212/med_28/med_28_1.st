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
    CurrentTime : TIME; (* Variable to hold the current time *)
    ElapsedBrewingTime : TIME; (* Variable to calculate elapsed brewing time *)
END_VAR

(* Initialize outputs *)
HeatingElement := FALSE;
AgitationMotor := FALSE;
HopsDispenser := FALSE;
FermentationTank := FALSE;

(* Control Logic *)
(* Update current time at the end of each PLC cycle *)
CurrentTime := TIME(); (* Assuming TIME() returns the current time *)

(* Calculate elapsed brewing time *)
ElapsedBrewingTime := CurrentTime - BrewingStartTime;

(* Heating Element Control *)
IF TemperatureSensor < 65.0 THEN
    HeatingElement := TRUE;
ELSE
    HeatingElement := FALSE;
END_IF;

(* Agitation Motor Control *)
IF WaterFlowSensor > 0.5 THEN
    AgitationMotor := TRUE;
ELSE
    AgitationMotor := FALSE;
END_IF;

(* Hops Dispenser Control *)
IF ElapsedBrewingTime >= T#5h THEN
    HopsDispenser := TRUE;
ELSE
    HopsDispenser := FALSE;
END_IF;

(* Fermentation Tank Control *)
IF ElapsedBrewingTime >= T#48h THEN
    FermentationTank := TRUE;
ELSE
    FermentationTank := FALSE;
END_IF;

END_FUNCTION_BLOCK