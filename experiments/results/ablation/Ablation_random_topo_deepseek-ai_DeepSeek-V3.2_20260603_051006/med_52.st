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
    tmrPair1 : TON;
    tmrPair2 : TON;
    prevCount1 : INT := 0;
    prevCount2 : INT := 0;
    prevCount3 : INT := 0;
    prevCount4 : INT := 0;
    intendedLight1 : BOOL := FALSE;
    intendedLight2 : BOOL := FALSE;
    intendedLight3 : BOOL := FALSE;
    intendedLight4 : BOOL := FALSE;
    countChangeDetected : BOOL;
END_VAR

(* Detect if any vehicle count has changed since last cycle *)
countChangeDetected := (prevCount1 <> VehicleCount1) OR 
                       (prevCount2 <> VehicleCount2) OR 
                       (prevCount3 <> VehicleCount3) OR 
                       (prevCount4 <> VehicleCount4);

(* Timer for Pair 1 (Intersections 1 & 2) - 5 second minimum green time *)
tmrPair1(
    IN := countChangeDetected,
    PT := T#5s
);

(* Timer for Pair 2 (Intersections 3 & 4) - 5 second minimum green time *)
tmrPair2(
    IN := countChangeDetected,
    PT := T#5s
);

(* Determine intended light states for Pair 1 based on vehicle counts *)
IF VehicleCount1 > VehicleCount2 THEN
    intendedLight1 := TRUE;
    intendedLight2 := FALSE;
ELSIF VehicleCount2 > VehicleCount1 THEN
    intendedLight1 := FALSE;
    intendedLight2 := TRUE;
ELSE
    (* If counts are equal, set both to red for safety *)
    intendedLight1 := FALSE;
    intendedLight2 := FALSE;
END_IF;

(* Determine intended light states for Pair 2 based on vehicle counts *)
IF VehicleCount3 > VehicleCount4 THEN
    intendedLight3 := TRUE;
    intendedLight4 := FALSE;
ELSIF VehicleCount4 > VehicleCount3 THEN
    intendedLight3 := FALSE;
    intendedLight4 := TRUE;
ELSE
    (* If counts are equal, set both to red for safety *)
    intendedLight3 := FALSE;
    intendedLight4 := FALSE;
END_IF;

(* Apply light states with timer logic to prevent rapid toggling *)
(* Pair 1: Only update lights if timer has elapsed or no change detected *)
IF NOT tmrPair1.Q AND countChangeDetected THEN
    (* Hold current states during timer period *)
    TrafficLight1 := TrafficLight1;
    TrafficLight2 := TrafficLight2;
ELSE
    (* Apply intended states when timer elapses *)
    TrafficLight1 := intendedLight1;
    TrafficLight2 := intendedLight2;
END_IF;

(* Pair 2: Only update lights if timer has elapsed or no change detected *)
IF NOT tmrPair2.Q AND countChangeDetected THEN
    (* Hold current states during timer period *)
    TrafficLight3 := TrafficLight3;
    TrafficLight4 := TrafficLight4;
ELSE
    (* Apply intended states when timer elapses *)
    TrafficLight3 := intendedLight3;
    TrafficLight4 := intendedLight4;
END_IF;

(* Update previous counts for next cycle *)
prevCount1 := VehicleCount1;
prevCount2 := VehicleCount2;
prevCount3 := VehicleCount3;
prevCount4 := VehicleCount4;

END_FUNCTION_BLOCK