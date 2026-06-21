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
    bFirstScan : BOOL := TRUE;
    bPrevState1 : BOOL := FALSE;
    bPrevState2 : BOOL := FALSE;
    bPrevState3 : BOOL := FALSE;
    bPrevState4 : BOOL := FALSE;
END_VAR

// Initialize on first scan
IF bFirstScan THEN
    TrafficLight1 := FALSE;
    TrafficLight2 := FALSE;
    TrafficLight3 := FALSE;
    TrafficLight4 := FALSE;
    
    bPrevState1 := FALSE;
    bPrevState2 := FALSE;
    bPrevState3 := FALSE;
    bPrevState4 := FALSE;
    
    bFirstScan := FALSE;
END_IF

// Process Intersection Pair 1 (Intersections 1 & 2)
IF VehicleCount1 > VehicleCount2 THEN
    // Intersection 1 has higher vehicle count
    TrafficLight1 := TRUE;
    TrafficLight2 := FALSE;
ELSIF VehicleCount2 > VehicleCount1 THEN
    // Intersection 2 has higher vehicle count
    TrafficLight1 := FALSE;
    TrafficLight2 := TRUE;
ELSE
    // Equal vehicle counts - maintain previous states
    TrafficLight1 := bPrevState1;
    TrafficLight2 := bPrevState2;
END_IF

// Process Intersection Pair 2 (Intersections 3 & 4)
IF VehicleCount3 > VehicleCount4 THEN
    // Intersection 3 has higher vehicle count
    TrafficLight3 := TRUE;
    TrafficLight4 := FALSE;
ELSIF VehicleCount4 > VehicleCount3 THEN
    // Intersection 4 has higher vehicle count
    TrafficLight3 := FALSE;
    TrafficLight4 := TRUE;
ELSE
    // Equal vehicle counts - maintain previous states
    TrafficLight3 := bPrevState3;
    TrafficLight4 := bPrevState4;
END_IF

// Store current states for next cycle (for tie-breaking)
bPrevState1 := TrafficLight1;
bPrevState2 := TrafficLight2;
bPrevState3 := TrafficLight3;
bPrevState4 := TrafficLight4;

END_FUNCTION_BLOCK