FUNCTION_BLOCK TrafficManagementSystem
VAR_INPUT
    VehicleCount1 : INT;
    VehicleCount2 : INT;
    VehicleCount3 : INT;
    VehicleCount4 : INT;
END_VAR

VAR_OUTPUT
    TrafficLight1 : BOOL;  (* TRUE = Green, FALSE = Red *)
    TrafficLight2 : BOOL;
    TrafficLight3 : BOOL;
    TrafficLight4 : BOOL;
END_VAR

VAR
    // Internal state variables for tie-breaking
    PrevPair1State : BOOL := TRUE;  (* Default to Intersection 1 green *)
    PrevPair2State : BOOL := TRUE;  (* Default to Intersection 3 green *)
END_VAR

(* Pair 1: Intersection 1 vs Intersection 2 *)
IF VehicleCount1 > VehicleCount2 THEN
    TrafficLight1 := TRUE;
    TrafficLight2 := FALSE;
    PrevPair1State := TRUE;
ELSIF VehicleCount2 > VehicleCount1 THEN
    TrafficLight1 := FALSE;
    TrafficLight2 := TRUE;
    PrevPair1State := FALSE;
ELSE
    (* Equal counts: use previous state to maintain complementary lights *)
    TrafficLight1 := PrevPair1State;
    TrafficLight2 := NOT PrevPair1State;
END_IF;

(* Pair 2: Intersection 3 vs Intersection 4 *)
IF VehicleCount3 > VehicleCount4 THEN
    TrafficLight3 := TRUE;
    TrafficLight4 := FALSE;
    PrevPair2State := TRUE;
ELSIF VehicleCount4 > VehicleCount3 THEN
    TrafficLight3 := FALSE;
    TrafficLight4 := TRUE;
    PrevPair2State := FALSE;
ELSE
    (* Equal counts: use previous state to maintain complementary lights *)
    TrafficLight3 := PrevPair2State;
    TrafficLight4 := NOT PrevPair2State;
END_IF;

END_FUNCTION_BLOCK