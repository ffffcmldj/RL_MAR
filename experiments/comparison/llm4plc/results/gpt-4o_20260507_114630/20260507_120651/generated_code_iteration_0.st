plaintext
START_ST
FUNCTION_BLOCK TrafficManagementSystem
VAR_INPUT
    VehicleCount1 : INT; // Vehicle count at intersection 1
    VehicleCount2 : INT; // Vehicle count at intersection 2
    VehicleCount3 : INT; // Vehicle count at intersection 3
    VehicleCount4 : INT; // Vehicle count at intersection 4
END_VAR

VAR_OUTPUT
    TrafficLight1 : BOOL; // Traffic light state for intersection 1 (TRUE = Green, FALSE = Red)
    TrafficLight2 : BOOL; // Traffic light state for intersection 2 (TRUE = Green, FALSE = Red)
    TrafficLight3 : BOOL; // Traffic light state for intersection 3 (TRUE = Green, FALSE = Red)
    TrafficLight4 : BOOL; // Traffic light state for intersection 4 (TRUE = Green, FALSE = Red)
END_VAR

VAR
    state : INT := 0; // Current state of the FSM
    prevState : INT := -1; // Previous state of the FSM
END_VAR

// Main logic of the traffic management system
CASE state OF
    // STATE 0: INITIALIZE
    0:
        // Initialize all traffic lights to red
        TrafficLight1 := FALSE;
        TrafficLight2 := FALSE;
        TrafficLight3 := FALSE;
        TrafficLight4 := FALSE;
        
        // Transition to STATE 1
        prevState := state;
        state := 1;

    // STATE 1: COMPARE VEHICLE COUNTS FOR PAIR 1 (INTERSECTIONS 1 AND 2)
    1:
        IF VehicleCount1 > VehicleCount2 THEN
            TrafficLight1 := TRUE;  // Intersection 1 gets green light
            TrafficLight2 := FALSE; // Intersection 2 gets red light
        ELSIF VehicleCount2 > VehicleCount1 THEN
            TrafficLight1 := FALSE; // Intersection 1 gets red light
            TrafficLight2 := TRUE;  // Intersection 2 gets green light
        END_IF;
        
        // Transition to STATE 2
        prevState := state;
        state := 2;

    // STATE 2: COMPARE VEHICLE COUNTS FOR PAIR 2 (INTERSECTIONS 3 AND 4)
    2:
        IF VehicleCount3 > VehicleCount4 THEN
            TrafficLight3 := TRUE;  // Intersection 3 gets green light
            TrafficLight4 := FALSE; // Intersection 4 gets red light
        ELSIF VehicleCount4 > VehicleCount3 THEN
            TrafficLight3 := FALSE; // Intersection 3 gets red light
            TrafficLight4 := TRUE;  // Intersection 4 gets green light
        END_IF;
        
        // Transition to STATE 3
        prevState := state;
        state := 3;

    // STATE 3: UPDATE TRAFFIC LIGHTS
    3:
        // Traffic light states are finalized and remain unchanged until the next cycle
        // Transition back to STATE 1 for the next cycle
        prevState := state;
        state := 1;

    // Default case (should not occur in normal operation)
    ELSE
        // Reset to STATE 0 in case of an invalid state
        prevState := state;
        state := 0;
END_CASE;
END_FUNCTION_BLOCK
END_ST