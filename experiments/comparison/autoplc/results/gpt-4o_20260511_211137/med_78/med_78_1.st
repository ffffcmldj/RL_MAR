FUNCTION_BLOCK RetractableRoofControl
    VAR_INPUT
        RainSensor : BOOL; (* Rain detection *)
        WindSensor : BOOL; (* Wind detection *)
        TemperatureSensor : REAL; (* Temperature input *)
    END_VAR
    VAR_OUTPUT
        RoofMotor : BOOL; (* Motor control *)
    END_VAR

    VAR
        (* Internal variables can be declared here if needed *)
    END_VAR

    (* Initialization *)
    RoofMotor := FALSE; (* Default state is to open the roof *)

    (* Priority Evaluation: Combined Rain and Wind Condition *)
    IF RainSensor AND WindSensor THEN
        RoofMotor := TRUE; (* Close the roof *)
        RETURN; (* Exit the function block *)
    END_IF

    (* Secondary Condition Evaluation: Rain Only Condition *)
    IF RainSensor THEN
        RoofMotor := TRUE; (* Close the roof *)
        RETURN; (* Exit the function block *)
    END_IF

    (* Temperature Evaluation: Low Temperature Condition *)
    IF TemperatureSensor < 20.0 THEN
        RoofMotor := TRUE; (* Close the roof *)
        RETURN; (* Exit the function block *)
    END_IF

    (* Normal Condition Handling *)
    RoofMotor := FALSE; (* Open the roof if none of the conditions are met *)

END_FUNCTION_BLOCK