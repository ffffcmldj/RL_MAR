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

(* Main logic *)
TrafficLight1 := (VehicleCount1 > VehicleCount2);
TrafficLight2 := NOT TrafficLight1;
TrafficLight3 := (VehicleCount3 > VehicleCount4);
TrafficLight4 := NOT TrafficLight3;

END_FUNCTION_BLOCK