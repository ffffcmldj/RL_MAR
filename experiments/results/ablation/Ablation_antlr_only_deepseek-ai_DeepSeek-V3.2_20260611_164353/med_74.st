(*
    TRAFFIC MANAGEMENT SYSTEM FUNCTION BLLOCK
    Description: Controls traffic lights for two independent road pairs based on vehicle counts.
    Logic: For each pair, the intersection with the higher vehicle count receives a green light (TRUE).
           In case of equal counts, a deterministic tie-breaker (alternating on equality) is applied.
           The system ensures exactly one green light per pair at all times.
    Design: Simple, deterministic, and robust with no external dependencies or timers.
*)

FUNCTION_BLOCK TrafficManagementSystem
VAR_INPUT
    VehicleCount1 : INT; (* Vehicle count at intersection 1 *)
    VehicleCount2 : INT; (* Vehicle count at intersection 2 *)
    VehicleCount3 : INT; (* Vehicle count at intersection 3 *)
    VehicleCount4 : INT; (* Vehicle count at intersection 4 *)
END_VAR
VAR_OUTPUT
    TrafficLight1 : BOOL; (* Green light control for intersection 1 *)
    TrafficLight2 : BOOL; (* Green light control for intersection 2 *)
    TrafficLight3 : BOOL; (* Green light control for intersection 3 *)
    TrafficLight4 : BOOL; (* Green light control for intersection 4 *)
END_VAR
VAR
    bPrevEqual1 : BOOL; (* Memory for tie-breaker state of pair 1 *)
    bPrevEqual2 : BOOL; (* Memory for tie-breaker state of pair 2 *)
END_VAR

(* Main execution logic *)
(* Process pair 1: Intersections 1 and 2 *)
IF VehicleCount1 > VehicleCount2 THEN
    TrafficLight1 := TRUE;
    TrafficLight2 := FALSE;
    bPrevEqual1 := FALSE; (* Reset tie-breaker memory on clear decision *)
ELSIF VehicleCount1 < VehicleCount2 THEN
    TrafficLight1 := FALSE;
    TrafficLight2 := TRUE;
    bPrevEqual1 := FALSE; (* Reset tie-breaker memory on clear decision *)
ELSE
    (* Equal counts: Apply deterministic tie-breaker (alternating) *)
    TrafficLight1 := NOT bPrevEqual1;
    TrafficLight2 := bPrevEqual1;
    bPrevEqual1 := NOT bPrevEqual1; (* Toggle state for next equality *)
END_IF;

(* Process pair 2: Intersections 3 and 4 *)
IF VehicleCount3 > VehicleCount4 THEN
    TrafficLight3 := TRUE;
    TrafficLight4 := FALSE;
    bPrevEqual2 := FALSE; (* Reset tie-breaker memory on clear decision *)
ELSIF VehicleCount3 < VehicleCount4 THEN
    TrafficLight3 := FALSE;
    TrafficLight4 := TRUE;
    bPrevEqual2 := FALSE; (* Reset tie-breaker memory on clear decision *)
ELSE
    (* Equal counts: Apply deterministic tie-breaker (alternating) *)
    TrafficLight3 := NOT bPrevEqual2;
    TrafficLight4 := bPrevEqual2;
    bPrevEqual2 := NOT bPrevEqual2; (* Toggle state for next equality *)
END_IF;

END_FUNCTION_BLOCK;