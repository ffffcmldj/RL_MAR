START_ST
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
 (* No temporary variables required for this logic *)
END_VAR

(* Logic for Intersection Pair 1: Intersection 1 vs Intersection 2 *)
(* If VehicleCount1 > VehicleCount2, TrafficLight1 is TRUE (Green), else FALSE (Red) *)
(* TrafficLight2 is the inverse of TrafficLight1 based on the comparison *)
IF VehicleCount1 > VehicleCount2 THEN
    TrafficLight1 := TRUE;
    TrafficLight2 := FALSE;
ELSE
    TrafficLight1 := FALSE;
    TrafficLight2 := TRUE;
END_IF;

(* Logic for Intersection Pair 2: Intersection 3 vs Intersection 4 *)
(* If VehicleCount3 > VehicleCount4, TrafficLight3 is TRUE (Green), else FALSE (Red) *)
(* TrafficLight4 is the inverse of TrafficLight3 based on the comparison *)
IF VehicleCount3 > VehicleCount4 THEN
    TrafficLight3 := TRUE;
    TrafficLight4 := FALSE;
ELSE
    TrafficLight3 := FALSE;
    TrafficLight4 := TRUE;
END_IF;

END_FUNCTION_BLOCK
END_ST