(*
FUNCTION_BLOCK: TrafficManagementSystem
DESCRIPTION: Smart road traffic management system that optimizes traffic flow through effective signal timings.
             Monitors vehicle counts at four intersections and compares pairs (1 vs 2 and 3 vs 4).
             Sets the intersection with higher vehicle count to green, with opposing intersections
             always having complementary light states.
AUTHOR: Senior PLC Commissioning Engineer
DATE: 2024-01-15
VERSION: 1.0
*)

FUNCTION_BLOCK TrafficManagementSystem
VAR_INPUT
    VehicleCount1 : INT;    (* Vehicle count at intersection 1 *)
    VehicleCount2 : INT;    (* Vehicle count at intersection 2 *)
    VehicleCount3 : INT;    (* Vehicle count at intersection 3 *)
    VehicleCount4 : INT;    (* Vehicle count at intersection 4 *)
END_VAR

VAR_OUTPUT
    TrafficLight1 : BOOL;   (* TRUE = Green, FALSE = Red for intersection 1 *)
    TrafficLight2 : BOOL;   (* TRUE = Green, FALSE = Red for intersection 2 *)
    TrafficLight3 : BOOL;   (* TRUE = Green, FALSE = Red for intersection 3 *)
    TrafficLight4 : BOOL;   (* TRUE = Green, FALSE = Red for intersection 4 *)
END_VAR

VAR
    (* Internal flags for pair 1 (intersections 1 & 2) *)
    Pair1_Count1Greater : BOOL;
    Pair1_Count2Greater : BOOL;
    
    (* Internal flags for pair 2 (intersections 3 & 4) *)
    Pair2_Count3Greater : BOOL;
    Pair2_Count4Greater : BOOL;
END_VAR

(*
LOGIC DESCRIPTION:
1. Compare vehicle counts for each pair independently
2. For each pair, determine which intersection has higher count
3. Set green for higher count, red for lower count
4. Handle equal counts with default (intersection 1/3 gets green)
5. Ensure complementary states within each pair
*)

(* --- PAIR 1: Intersections 1 and 2 --- *)
(* Determine comparison results for pair 1 *)
Pair1_Count1Greater := VehicleCount1 > VehicleCount2;
Pair1_Count2Greater := VehicleCount2 > VehicleCount1;

(* Set traffic lights for pair 1 based on comparison *)
IF Pair1_Count1Greater THEN
    (* Intersection 1 has more vehicles *)
    TrafficLight1 := TRUE;   (* Green *)
    TrafficLight2 := FALSE;  (* Red *)
ELSIF Pair1_Count2Greater THEN
    (* Intersection 2 has more vehicles *)
    TrafficLight1 := FALSE;  (* Red *)
    TrafficLight2 := TRUE;   (* Green *)
ELSE
    (* Equal counts: default to intersection 1 green *)
    TrafficLight1 := TRUE;   (* Green *)
    TrafficLight2 := FALSE;  (* Red *)
END_IF;

(* --- PAIR 2: Intersections 3 and 4 --- *)
(* Determine comparison results for pair 2 *)
Pair2_Count3Greater := VehicleCount3 > VehicleCount4;
Pair2_Count4Greater := VehicleCount4 > VehicleCount3;

(* Set traffic lights for pair 2 based on comparison *)
IF Pair2_Count3Greater THEN
    (* Intersection 3 has more vehicles *)
    TrafficLight3 := TRUE;   (* Green *)
    TrafficLight4 := FALSE;  (* Red *)
ELSIF Pair2_Count4Greater THEN
    (* Intersection 4 has more vehicles *)
    TrafficLight3 := FALSE;  (* Red *)
    TrafficLight4 := TRUE;   (* Green *)
ELSE
    (* Equal counts: default to intersection 3 green *)
    TrafficLight3 := TRUE;   (* Green *)
    TrafficLight4 := FALSE;  (* Red *)
END_IF;

END_FUNCTION_BLOCK