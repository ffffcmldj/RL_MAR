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
 TempPair1 : BOOL;
 TempPair2 : BOOL;
END_VAR

TempPair1 := (VehicleCount1 > VehicleCount2);
TempPair2 := (VehicleCount3 > VehicleCount4);

IF TempPair1 THEN
    TrafficLight1 := TRUE;
    TrafficLight2 := FALSE;
ELSE
    TrafficLight1 := FALSE;
    TrafficLight2 := TRUE;
END_IF;

IF TempPair2 THEN
    TrafficLight3 := TRUE;
    TrafficLight4 := FALSE;
ELSE
    TrafficLight3 := FALSE;
    TrafficLight4 := TRUE;
END_IF;

END_FUNCTION_BLOCK