START_ST
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
    state : INT;
END_VAR

CASE state OF
    0: (* STATE 0: INITIALIZE *)
        TrafficLight1 := FALSE;
        TrafficLight2 := FALSE;
        TrafficLight3 := FALSE;
        TrafficLight4 := FALSE;
        state := 1; (* Transition to STATE 1: OPERATIONAL *)

    1: (* STATE 1: OPERATIONAL *)
        (* Pair 1: Intersections 1 and 2 *)
        IF VehicleCount1 > VehicleCount2 THEN
            TrafficLight1 := TRUE;
            TrafficLight2 := FALSE;
        ELSE
            TrafficLight1 := FALSE;
            TrafficLight2 := TRUE;
        END_IF;

        (* Pair 2: Intersections 3 and 4 *)
        IF VehicleCount3 > VehicleCount4 THEN
            TrafficLight3 := TRUE;
            TrafficLight4 := FALSE;
        ELSE
            TrafficLight3 := FALSE;
            TrafficLight4 := TRUE;
        END_IF;

        state := 1; (* Remain in STATE 1: OPERATIONAL *)

END_CASE;

END_FUNCTION_BLOCK
END_ST