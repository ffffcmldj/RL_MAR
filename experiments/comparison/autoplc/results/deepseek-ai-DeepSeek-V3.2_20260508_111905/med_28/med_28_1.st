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
    CurrentTime : TIME; (* Current system time *)
    ElapsedTime : TIME; (* Elapsed brewing time *)
    FiveHours : TIME := T#5h; (* 5 hours constant *)
    FortyEightHours : TIME := T#48h; (* 48 hours constant *)
END_VAR

(* Get current system time *)
CurrentTime := TIME();

(* Calculate elapsed brewing time *)
IF BrewingStartTime <= CurrentTime THEN
    ElapsedTime := CurrentTime - BrewingStartTime;
ELSE
    (* If start time is in the future, elapsed time is 0 *)
    ElapsedTime := T#0s;
END_IF

(* Temperature control logic *)
IF TemperatureSensor < 65.0 THEN
    HeatingElement := TRUE;
ELSE
    HeatingElement := FALSE;
END_IF

(* Water flow control logic *)
IF WaterFlowSensor > 0.5 THEN
    AgitationMotor := TRUE;
ELSE
    AgitationMotor := FALSE;
END_IF

(* Hops dispenser control logic - activate after 5 hours *)
IF ElapsedTime >= FiveHours THEN
    HopsDispenser := TRUE;
ELSE
    HopsDispenser := FALSE;
END_IF

(* Fermentation tank control logic - activate after 48 hours *)
IF ElapsedTime >= FortyEightHours THEN
    FermentationTank := TRUE;
ELSE
    FermentationTank := FALSE;
END_IF

END_FUNCTION_BLOCK