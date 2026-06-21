FUNCTION_BLOCK TrafficManagementSystem
VAR_INPUT
    VehicleCount1 : INT;
    VehicleCount2 : INT;
    VehicleCount3 : INT;
    VehicleCount4 : INT;
END_VAR

VAR_OUTPUT
    TrafficLight1 : BOOL;
    TrafficLight2 : BOOL;
    TrafficLight3 : BOOL;
    TrafficLight4 : BOOL;
END_VAR

VAR
    // No internal variables needed for this implementation
END_VAR

// Pair 1: Intersection 1 vs Intersection 2
IF VehicleCount1 > VehicleCount2 THEN
    TrafficLight1 := TRUE;   // Green for intersection with higher count
    TrafficLight2 := FALSE;  // Red for the other intersection
ELSIF VehicleCount2 > VehicleCount1 THEN
    TrafficLight1 := FALSE;  // Red for intersection with lower count
    TrafficLight2 := TRUE;   // Green for the other intersection
ELSE
    // Equal counts: default priority to Intersection 1
    TrafficLight1 := TRUE;   // Green for Intersection 1
    TrafficLight2 := FALSE;  // Red for Intersection 2
END_IF;

// Pair 2: Intersection 3 vs Intersection 4
IF VehicleCount3 > VehicleCount4 THEN
    TrafficLight3 := TRUE;   // Green for intersection with higher count
    TrafficLight4 := FALSE;  // Red for the other intersection
ELSIF VehicleCount4 > VehicleCount3 THEN
    TrafficLight3 := FALSE;  // Red for intersection with lower count
    TrafficLight4 := TRUE;   // Green for the other intersection
ELSE
    // Equal counts: default priority to Intersection 3
    TrafficLight3 := TRUE;   // Green for Intersection 3
    TrafficLight4 := FALSE;  // Red for Intersection 4
END_IF;

END_FUNCTION_BLOCK