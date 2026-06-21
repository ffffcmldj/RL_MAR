FUNCTION_BLOCK TrafficManagementSystem
VAR_INPUT
    VehicleCount1 : INT;
    VehicleCount2 : INT;
    VehicleCount3 : INT;
    VehicleCount4 : INT;
END_VAR

VAR_OUTPUT
    TrafficLight1 : BOOL := FALSE; // Initialize to Red
    TrafficLight2 : BOOL := FALSE; // Initialize to Red
    TrafficLight3 : BOOL := FALSE; // Initialize to Red
    TrafficLight4 : BOOL := FALSE; // Initialize to Red
END_VAR

VAR
    // Temporary variables for comparison
    TempLight1 : BOOL;
    TempLight2 : BOOL;
    TempLight3 : BOOL;
    TempLight4 : BOOL;
END_VAR

// Continuous monitoring and comparison logic
IF VehicleCount1 > VehicleCount2 THEN
    TempLight1 := TRUE; // Set TrafficLight1 to Green
    TempLight2 := FALSE; // Set TrafficLight2 to Red
ELSE
    TempLight1 := FALSE; // Set TrafficLight1 to Red
    TempLight2 := TRUE; // Set TrafficLight2 to Green
END_IF;

IF VehicleCount3 > VehicleCount4 THEN
    TempLight3 := TRUE; // Set TrafficLight3 to Green
    TempLight4 := FALSE; // Set TrafficLight4 to Red
ELSE
    TempLight3 := FALSE; // Set TrafficLight3 to Red
    TempLight4 := TRUE; // Set TrafficLight4 to Green
END_IF;

// Update the output states based on temporary variables
TrafficLight1 := TempLight1;
TrafficLight2 := TempLight2;
TrafficLight3 := TempLight3;
TrafficLight4 := TempLight4;

END_FUNCTION_BLOCK