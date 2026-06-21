FUNCTION_BLOCK TrafficManagementSystem
    VAR_INPUT
        VehicleCount1 : INT; (* Input for vehicle count at intersection 1 *)
        VehicleCount2 : INT; (* Input for vehicle count at intersection 2 *)
        VehicleCount3 : INT; (* Input for vehicle count at intersection 3 *)
        VehicleCount4 : INT; (* Input for vehicle count at intersection 4 *)
    END_VAR

    VAR_OUTPUT
        TrafficLight1 : BOOL; (* Output for traffic light at intersection 1 *)
        TrafficLight2 : BOOL; (* Output for traffic light at intersection 2 *)
        TrafficLight3 : BOOL; (* Output for traffic light at intersection 3 *)
        TrafficLight4 : BOOL; (* Output for traffic light at intersection 4 *)
    END_VAR

    VAR
        // Temporary variables for comparison
        TempCount1 : INT;
        TempCount2 : INT;
        TempCount3 : INT;
        TempCount4 : INT;
    END_VAR

    // Initialize traffic lights to RED (FALSE)
    TrafficLight1 := FALSE;
    TrafficLight2 := FALSE;
    TrafficLight3 := FALSE;
    TrafficLight4 := FALSE;

    // Compare VehicleCount1 and VehicleCount2
    IF VehicleCount1 > VehicleCount2 THEN
        TrafficLight1 := TRUE;  // Set TrafficLight1 to GREEN
        TrafficLight2 := FALSE; // Set TrafficLight2 to RED
    ELSIF VehicleCount2 > VehicleCount1 THEN
        TrafficLight2 := TRUE;  // Set TrafficLight2 to GREEN
        TrafficLight1 := FALSE; // Set TrafficLight1 to RED
    END_IF;

    // Compare VehicleCount3 and VehicleCount4
    IF VehicleCount3 > VehicleCount4 THEN
        TrafficLight3 := TRUE;  // Set TrafficLight3 to GREEN
        TrafficLight4 := FALSE; // Set TrafficLight4 to RED
    ELSIF VehicleCount4 > VehicleCount3 THEN
        TrafficLight4 := TRUE;  // Set TrafficLight4 to GREEN
        TrafficLight3 := FALSE; // Set TrafficLight3 to RED
    END_IF;
END_FUNCTION_BLOCK