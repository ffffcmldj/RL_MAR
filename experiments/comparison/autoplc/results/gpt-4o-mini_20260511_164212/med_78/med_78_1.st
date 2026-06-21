FUNCTION_BLOCK RetractableRoofControl
    VAR_INPUT
        RainSensor : BOOL; (* Rain detection *)
        WindSensor : BOOL; (* Wind detection *)
        TemperatureSensor : REAL; (* Temperature input *)
    END_VAR
    VAR_OUTPUT
        RoofMotor : BOOL; (* Motor control *)
    END_VAR

    // Initialize RoofMotor to FALSE (roof open)
    RoofMotor := FALSE;

    // Check conditions in order of priority
    IF RainSensor AND WindSensor THEN
        // Combined Rain and Wind condition
        RoofMotor := TRUE; // Close the roof
    ELSE
        IF RainSensor THEN
            // Rain only condition
            RoofMotor := TRUE; // Close the roof
        ELSE
            IF TemperatureSensor < 20.0 THEN
                // Low Temperature condition
                RoofMotor := TRUE; // Close the roof
            ELSE
                // Normal Conditions
                RoofMotor := FALSE; // Open the roof
            END_IF;
        END_IF;
    END_IF;

END_FUNCTION_BLOCK