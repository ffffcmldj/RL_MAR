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
    CurrentTime : TIME; (* Variable to store the current time *)
    ElapsedTime : TIME; (* Variable to store the elapsed brewing time *)
END_VAR

(* Initialization of outputs to a safe state *)
HeatingElement := FALSE;
AgitationMotor := FALSE;
HopsDispenser := FALSE;
FermentationTank := FALSE;

(* Get the current time *)
CurrentTime := TIME(); (* Assuming TIME() gives the current time *)

(* Calculate the elapsed brewing time *)
ElapsedTime := CurrentTime - BrewingStartTime;

(* Heating Element Control Logic *)
IF TemperatureSensor < 65.0 THEN
    HeatingElement := TRUE;
ELSE
    HeatingElement := FALSE;
END_IF;

(* Agitation Motor Control Logic *)
IF WaterFlowSensor > 0.5 THEN
    AgitationMotor := TRUE;
ELSE
    AgitationMotor := FALSE;
END_IF;

(* Hops Dispenser Control Logic *)
IF ElapsedTime >= T#5h THEN
    HopsDispenser := TRUE;
ELSE
    HopsDispenser := FALSE;
END_IF;

(* Fermentation Tank Control Logic *)
IF ElapsedTime >= T#48h THEN
    FermentationTank := TRUE;
ELSE
    FermentationTank := FALSE;
END_IF;

END_FUNCTION_BLOCK