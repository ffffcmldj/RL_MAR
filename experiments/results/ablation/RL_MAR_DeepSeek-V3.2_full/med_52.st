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
    (* No internal variables required for this logic *)
END_VAR

(* Main logic for intersection pair 1 and 2 *)
IF VehicleCount1 > VehicleCount2 THEN
    TrafficLight1 := TRUE;
    TrafficLight2 := FALSE;
ELSIF VehicleCount2 > VehicleCount1 THEN
    TrafficLight1 := FALSE;
    TrafficLight2 := TRUE;
ELSE
    (* Equal counts: default to intersection 1 green *)
    TrafficLight1 := TRUE;
    TrafficLight2 := FALSE;
END_IF;

(* Main logic for intersection pair 3 and 4 *)
IF VehicleCount3 > VehicleCount4 THEN
    TrafficLight3 := TRUE;
    TrafficLight4 := FALSE;
ELSIF VehicleCount4 > VehicleCount3 THEN
    TrafficLight3 := FALSE;
    TrafficLight4 := TRUE;
ELSE
    (* Equal counts: default to intersection 3 green *)
    TrafficLight3 := TRUE;
    TrafficLight4 := FALSE;
END_IF;

END_FUNCTION_BLOCK;