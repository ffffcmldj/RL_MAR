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
    // Internal variables to handle tie conditions and maintain state
    bDefaultStatePair1 : BOOL := TRUE;
    bDefaultStatePair2 : BOOL := TRUE;
END_VAR

(* Pair 1: Intersection 1 vs Intersection 2 - Independent Management *)
IF VehicleCount1 > VehicleCount2 THEN
    TrafficLight1 := TRUE;
    TrafficLight2 := FALSE;
    bDefaultStatePair1 := TRUE;  // Update default for next tie
ELSIF VehicleCount2 > VehicleCount1 THEN
    TrafficLight1 := FALSE;
    TrafficLight2 := TRUE;
    bDefaultStatePair1 := FALSE;  // Update default for next tie
ELSE
    (* If counts are equal, use alternating default logic *)
    TrafficLight1 := bDefaultStatePair1;
    TrafficLight2 := NOT bDefaultStatePair1;
    bDefaultStatePair1 := NOT bDefaultStatePair1;  // Toggle for next tie
END_IF;

(* Pair 2: Intersection 3 vs Intersection 4 - Independent Management *)
IF VehicleCount3 > VehicleCount4 THEN
    TrafficLight3 := TRUE;
    TrafficLight4 := FALSE;
    bDefaultStatePair2 := TRUE;  // Update default for next tie
ELSIF VehicleCount4 > VehicleCount3 THEN
    TrafficLight3 := FALSE;
    TrafficLight4 := TRUE;
    bDefaultStatePair2 := FALSE;  // Update default for next tie
ELSE
    (* If counts are equal, use alternating default logic *)
    TrafficLight3 := bDefaultStatePair2;
    TrafficLight4 := NOT bDefaultStatePair2;
    bDefaultStatePair2 := NOT bDefaultStatePair2;  // Toggle for next tie
END_IF;

END_FUNCTION_BLOCK