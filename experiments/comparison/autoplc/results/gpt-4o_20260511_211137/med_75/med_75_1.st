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
        CurrentTime : TIME; (* Variable to store current time *)
        ElapsedTime : TIME; (* Variable to store elapsed brewing time *)
    END_VAR

    (* Initialization *)
    HeatingElement := FALSE;
    AgitationMotor := FALSE;
    HopsDispenser := FALSE;
    FermentationTank := FALSE;

    (* Temperature Control Logic *)
    IF TemperatureSensor < 65.0 THEN
        HeatingElement := TRUE;
    ELSE
        HeatingElement := FALSE;
    END_IF

    (* Agitation Control Logic *)
    IF WaterFlowSensor > 0.5 THEN
        AgitationMotor := TRUE;
    ELSE
        AgitationMotor := FALSE;
    END_IF

    (* Calculate Elapsed Time *)
    CurrentTime := TIME(); (* Assume TIME() returns the current time *)
    ElapsedTime := CurrentTime - BrewingStartTime;

    (* Hops Dispensing Logic *)
    IF ElapsedTime >= T#5h THEN
        HopsDispenser := TRUE;
    ELSE
        HopsDispenser := FALSE;
    END_IF

    (* Fermentation Transfer Logic *)
    IF ElapsedTime >= T#48h THEN
        FermentationTank := TRUE;
    ELSE
        FermentationTank := FALSE;
    END_IF
END_FUNCTION_BLOCK