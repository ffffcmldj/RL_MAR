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
        CurrentTime : TIME; (* Variable to hold the current time *)
        ElapsedBrewingTime : TIME; (* Variable to calculate elapsed brewing time *)
    END_VAR

    (* Initialize outputs *)
    HeatingElement := FALSE;
    AgitationMotor := FALSE;
    HopsDispenser := FALSE;
    FermentationTank := FALSE;

    (* Continuous execution logic *)
    CurrentTime := TIME(); (* Get the current time *)

    (* Temperature Control Logic *)
    IF TemperatureSensor < 65.0 THEN
        HeatingElement := TRUE; (* Activate heating element *)
    ELSE
        HeatingElement := FALSE; (* Deactivate heating element *)
    END_IF;

    (* Agitation Motor Control Logic *)
    IF WaterFlowSensor > 0.5 THEN
        AgitationMotor := TRUE; (* Activate agitation motor *)
    ELSE
        AgitationMotor := FALSE; (* Deactivate agitation motor *)
    END_IF;

    (* Calculate elapsed brewing time *)
    ElapsedBrewingTime := CurrentTime - BrewingStartTime;

    (* Hops Dispensing Logic *)
    IF ElapsedBrewingTime >= T#5h THEN
        HopsDispenser := TRUE; (* Activate hops dispenser *)
    ELSE
        HopsDispenser := FALSE; (* Deactivate hops dispenser *)
    END_IF;

    (* Fermentation Tank Transfer Logic *)
    IF ElapsedBrewingTime >= T#48h THEN
        FermentationTank := TRUE; (* Activate fermentation tank transfer *)
    ELSE
        FermentationTank := FALSE; (* Deactivate fermentation tank transfer *)
    END_IF;

END_FUNCTION_BLOCK