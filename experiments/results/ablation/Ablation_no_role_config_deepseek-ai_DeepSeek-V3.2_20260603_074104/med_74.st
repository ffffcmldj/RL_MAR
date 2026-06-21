FUNCTION_BLOCK TrafficManagementSystem
VAR_INPUT
    VehicleCount1 : INT; (* Vehicle count at intersection 1 *)
    VehicleCount2 : INT; (* Vehicle count at intersection 2 *)
    VehicleCount3 : INT; (* Vehicle count at intersection 3 *)
    VehicleCount4 : INT; (* Vehicle count at intersection 4 *)
END_VAR

VAR_OUTPUT
    TrafficLight1 : BOOL; (* TRUE = Green, FALSE = Red *)
    TrafficLight2 : BOOL; (* TRUE = Green, FALSE = Red *)
    TrafficLight3 : BOOL; (* TRUE = Green, FALSE = Red *)
    TrafficLight4 : BOOL; (* TRUE = Green, FALSE = Red *)
END_VAR

VAR
    (* Internal state variables for clarity *)
    TrafficLightState1 : BOOL;
    TrafficLightState2 : BOOL;
    TrafficLightState3 : BOOL;
    TrafficLightState4 : BOOL;
END_VAR

(* Control logic for intersection pair 1 (Intersection 1 and 2) *)
IF VehicleCount1 > VehicleCount2 THEN
    TrafficLightState1 := TRUE;   (* Green for intersection 1 *)
    TrafficLightState2 := FALSE;  (* Red for intersection 2 *)
ELSIF VehicleCount1 < VehicleCount2 THEN
    TrafficLightState1 := FALSE;  (* Red for intersection 1 *)
    TrafficLightState2 := TRUE;   (* Green for intersection 2 *)
ELSE
    (* Equal counts: both red for safety *)
    TrafficLightState1 := FALSE;
    TrafficLightState2 := FALSE;
END_IF;

(* Control logic for intersection pair 2 (Intersection 3 and 4) *)
IF VehicleCount3 > VehicleCount4 THEN
    TrafficLightState3 := TRUE;   (* Green for intersection 3 *)
    TrafficLightState4 := FALSE;  (* Red for intersection 4 *)
ELSIF VehicleCount3 < VehicleCount4 THEN
    TrafficLightState3 := FALSE;  (* Red for intersection 3 *)
    TrafficLightState4 := TRUE;   (* Green for intersection 4 *)
ELSE
    (* Equal counts: both red for safety *)
    TrafficLightState3 := FALSE;
    TrafficLightState4 := FALSE;
END_IF;

(* Assign internal states to outputs *)
TrafficLight1 := TrafficLightState1;
TrafficLight2 := TrafficLightState2;
TrafficLight3 := TrafficLightState3;
TrafficLight4 := TrafficLightState4;

END_FUNCTION_BLOCK