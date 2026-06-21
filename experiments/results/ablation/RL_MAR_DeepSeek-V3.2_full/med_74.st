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
    (* No internal variables needed for this simplified implementation *)
END_VAR

(* Main logic for intersection pair 1 (Intersections 1 and 2) *)
IF VehicleCount1 > VehicleCount2 THEN
    TrafficLight1 := TRUE;
    TrafficLight2 := FALSE;
ELSIF VehicleCount1 < VehicleCount2 THEN
    TrafficLight1 := FALSE;
    TrafficLight2 := TRUE;
ELSE
    TrafficLight1 := FALSE;
    TrafficLight2 := FALSE;
END_IF;

(* Main logic for intersection pair 2 (Intersections 3 and 4) *)
IF VehicleCount3 > VehicleCount4 THEN
    TrafficLight3 := TRUE;
    TrafficLight4 := FALSE;
ELSIF VehicleCount3 < VehicleCount4 THEN
    TrafficLight3 := FALSE;
    TrafficLight4 := TRUE;
ELSE
    TrafficLight3 := FALSE;
    TrafficLight4 := FALSE;
END_IF;

END_FUNCTION_BLOCK;