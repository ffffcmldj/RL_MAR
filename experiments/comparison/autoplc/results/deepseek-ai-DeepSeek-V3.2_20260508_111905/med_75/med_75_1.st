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
    bHopsDispensed : BOOL; (* Internal flag for hops dispenser *)
    bTankTransferred : BOOL; (* Internal flag for fermentation tank *)
    tElapsedTime : TIME; (* Internal variable for elapsed brewing time *)
    tCurrentTime : TIME; (* Internal variable for current time *)
    tFiveHours : TIME := T#5h; (* Constant for 5 hours *)
    tFortyEightHours : TIME := T#48h; (* Constant for 48 hours *)
    bFirstScan : BOOL := TRUE; (* First scan detection flag *)
    tPrevStartTime : TIME; (* Previous brewing start time for change detection *)
END_VAR

(* Initialization and reset logic *)
IF bFirstScan THEN
    bFirstScan := FALSE;
    bHopsDispensed := FALSE;
    bTankTransferred := FALSE;
    HeatingElement := FALSE;
    AgitationMotor := FALSE;
    HopsDispenser := FALSE;
    FermentationTank := FALSE;
    tPrevStartTime := BrewingStartTime;
END_IF

(* Check if brewing start time has changed - reset flags if changed *)
IF BrewingStartTime <> tPrevStartTime THEN
    bHopsDispensed := FALSE;
    bTankTransferred := FALSE;
    HopsDispenser := FALSE;
    FermentationTank := FALSE;
    tPrevStartTime := BrewingStartTime;
END_IF

(* Get current time and calculate elapsed brewing time *)
tCurrentTime := TIME();
tElapsedTime := tCurrentTime - BrewingStartTime;

(* Ensure elapsed time is not negative *)
IF tElapsedTime < T#0s THEN
    tElapsedTime := T#0s;
END_IF

(* Temperature control logic *)
IF TemperatureSensor < 65.0 THEN
    HeatingElement := TRUE;
ELSE
    HeatingElement := FALSE;
END_IF

(* Agitation motor control logic *)
IF WaterFlowSensor > 0.5 THEN
    AgitationMotor := TRUE;
ELSE
    AgitationMotor := FALSE;
END_IF

(* Hops dispensing logic *)
IF (tElapsedTime >= tFiveHours) AND (NOT bHopsDispensed) THEN
    HopsDispenser := TRUE;
    bHopsDispensed := TRUE;
END_IF

(* Fermentation tank transfer logic *)
IF (tElapsedTime >= tFortyEightHours) AND (NOT bTankTransferred) THEN
    FermentationTank := TRUE;
    bTankTransferred := TRUE;
END_IF

END_FUNCTION_BLOCK