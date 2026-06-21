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
    lastWinnerPair1 : BOOL := FALSE;
    lastWinnerPair2 : BOOL := FALSE;
END_VAR

(* State: RUNNING - Process vehicle counts and set lights accordingly *)
(* For Intersection Pair 1-2 *)
IF VehicleCount1 > VehicleCount2 THEN
    TrafficLight1 := TRUE;
    TrafficLight2 := FALSE;
    lastWinnerPair1 := TRUE;
ELSIF VehicleCount2 > VehicleCount1 THEN
    TrafficLight1 := FALSE;
    TrafficLight2 := TRUE;
    lastWinnerPair1 := FALSE;
ELSE
    (* Equal counts: use tie-breaking (maintain last state) *)
    TrafficLight1 := lastWinnerPair1;
    TrafficLight2 := NOT lastWinnerPair1;
END_IF;

(* For Intersection Pair 3-4 *)
IF VehicleCount3 > VehicleCount4 THEN
    TrafficLight3 := TRUE;
    TrafficLight4 := FALSE;
    lastWinnerPair2 := TRUE;
ELSIF VehicleCount4 > VehicleCount3 THEN
    TrafficLight3 := FALSE;
    TrafficLight4 := TRUE;
    lastWinnerPair2 := FALSE;
ELSE
    (* Equal counts: use tie-breaking (maintain last state) *)
    TrafficLight3 := lastWinnerPair2;
    TrafficLight4 := NOT lastWinnerPair2;
END_IF;

END_FUNCTION_BLOCK
END_ST