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
    TemperatureSetpoint : REAL := 65.0;
    FlowThreshold : REAL := 0.5;
    HopsDispenseTime : TIME := T#5h;
    FermentationStartTime : TIME := T#48h;
END_VAR

    (* Calculate current time and elapsed brewing time *)
    CurrentTime := TIME();
    ElapsedBrewingTime := CurrentTime - BrewingStartTime;

    (* Control Heating Element based on temperature *)
    IF TemperatureSensor < TemperatureSetpoint THEN
        HeatingElement := TRUE;
    ELSE
        HeatingElement := FALSE;
    END_IF;

    (* Control Agitation Motor based on water flow *)
    IF WaterFlowSensor > FlowThreshold THEN
        AgitationMotor := TRUE;
    ELSE
        AgitationMotor := FALSE;
    END_IF;

    (* Control Hops Dispenser after 5 hours of brewing *)
    IF ElapsedBrewingTime >= HopsDispenseTime THEN
        HopsDispenser := TRUE;
    ELSE
        HopsDispenser := FALSE;
    END_IF;

    (* Control Fermentation Tank after 48 hours of brewing *)
    IF ElapsedBrewingTime >= FermentationStartTime THEN
        FermentationTank := TRUE;
    ELSE
        FermentationTank := FALSE;
    END_IF;

END_FUNCTION_BLOCK