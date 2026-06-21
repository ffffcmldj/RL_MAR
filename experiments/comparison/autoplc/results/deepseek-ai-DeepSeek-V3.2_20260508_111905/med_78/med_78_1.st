FUNCTION_BLOCK RetractableRoofControl
VAR_INPUT
    RainSensor : BOOL; (* Rain detection *)
    WindSensor : BOOL; (* Wind detection *)
    TemperatureSensor : REAL; (* Temperature input *)
END_VAR
VAR_OUTPUT
    RoofMotor : BOOL; (* Motor control *)
END_VAR


    (* Combined Rain and Wind - Highest Priority *)
    IF RainSensor AND WindSensor THEN
        RoofMotor := TRUE; (* Close roof *)
        RETURN; (* Exit function block *)
    END_IF;
    
    (* Rain Only - Medium Priority *)
    IF RainSensor THEN
        RoofMotor := TRUE; (* Close roof *)
        RETURN; (* Exit function block *)
    END_IF;
    
    (* Low Temperature - Lowest Priority *)
    IF TemperatureSensor < 20.0 THEN
        RoofMotor := TRUE; (* Close roof *)
    ELSE
        (* Normal Conditions *)
        RoofMotor := FALSE; (* Open roof *)
    END_IF;
    
END_FUNCTION_BLOCK