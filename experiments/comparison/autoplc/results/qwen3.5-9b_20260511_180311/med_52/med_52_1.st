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
    TempCount1 : INT;
    TempCount2 : INT;
    TempCount3 : INT;
    TempCount4 : INT;
END_VAR

TempCount1 := VehicleCount1;
TempCount2 := VehicleCount2;
TempCount3 := VehicleCount3;
TempCount4 := VehicleCount4;

IF TempCount1 > TempCount2 THEN
    TrafficLight1 := TRUE;
    TrafficLight2 := FALSE;
ELSIF TempCount2 > TempCount1 THEN
    TrafficLight1 := FALSE;
    TrafficLight2 := TRUE;
ELSE
    TrafficLight1 := TRUE;
    TrafficLight2 := FALSE;
END_IF;

IF TempCount3 > TempCount4 THEN
    TrafficLight3 := TRUE;
    TrafficLight4 := FALSE;
ELSIF TempCount4 > TempCount3 THEN
    TrafficLight3 := FALSE;
    TrafficLight4 := TRUE;
ELSE
    TrafficLight3 := TRUE;
    TrafficLight4 := FALSE;
END_IF;

END_FUNCTION_BLOCK