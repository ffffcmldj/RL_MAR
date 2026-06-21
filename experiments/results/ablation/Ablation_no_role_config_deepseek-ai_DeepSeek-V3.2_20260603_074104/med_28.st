FUNCTION_BLOCK HomeBrewingSystem
VAR_INPUT
    TemperatureSensor : REAL;     (* Input for temperature measurement *)
    WaterFlowSensor : REAL;       (* Input for water flow measurement *)
    BrewingStartTime : TIME;      (* Input for brewing start time *)
    BrewingDuration : TIME;       (* Input for brewing duration *)
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL;        (* Output for heating element *)
    AgitationMotor : BOOL;        (* Output for agitation motor *)
    HopsDispenser : BOOL;         (* Output for hops dispenser *)
    FermentationTank : BOOL;      (* Output for fermentation tank *)
END_VAR
VAR
    CurrentTime : TIME;           (* Current system time *)
    ElapsedTime : TIME;           (* Time elapsed since brewing start *)
END_VAR

    (* Get current time and calculate elapsed brewing time *)
    CurrentTime := TIME();
    ElapsedTime := CurrentTime - BrewingStartTime;

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
    IF ElapsedTime >= T#5h THEN
        HopsDispenser := TRUE;
    ELSE
        HopsDispenser := FALSE;
    END_IF;

    (* Control fermentation tank - activate after 48 hours of brewing *)
    IF ElapsedTime >= T#48h THEN
        FermentationTank := TRUE;
    ELSE
        FermentationTank := FALSE;
    END_IF;

END_FUNCTION_BLOCK