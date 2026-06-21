TYPE T_GARAGE_SLOT:
STRUCT
    Occupied : BOOL;
    VehicleNumber : INT;
END_STRUCT;
END_TYPE

TYPE T_TRUCK_INFO:
STRUCT
    row : INT;
    col : INT;
    VehicleNumber : INT;
END_STRUCT;
END_TYPE

FUNCTION_BLOCK TruckGarage
VAR_INPUT
    enter_flag : BOOL;
    exit_flag : BOOL;
    VehicleNumber_in : INT;
END_VAR

VAR_OUTPUT
    truck : T_TRUCK_INFO;
END_VAR

VAR_IN_OUT
    garage : ARRAY[1..3, 1..5] OF T_GARAGE_SLOT;
END_VAR

VAR
    i : INT;
    j : INT;
    found : BOOL;
END_VAR

// Initialization of garage
FOR i := 1 TO 3 DO
    FOR j := 1 TO 5 DO
        garage[i, j].Occupied := FALSE;
        garage[i, j].VehicleNumber := 0;
    END_FOR;
END_FOR;

// Main control logic
IF enter_flag THEN
    found := FALSE;
    // Search for an available parking space
    FOR i := 3 TO 1 BY -1 DO
        FOR j := 5 TO 1 BY -1 DO
            IF NOT garage[i, j].Occupied THEN
                garage[i, j].Occupied := TRUE;
                garage[i, j].VehicleNumber := VehicleNumber_in;
                truck.row := i;
                truck.col := j;
                truck.VehicleNumber := VehicleNumber_in;
                found := TRUE;
                EXIT; // Exit inner loop
            END_IF;
        END_FOR;
        IF found THEN
            EXIT; // Exit outer loop
        END_IF;
    END_FOR;
    // Reset enter_flag after processing
    enter_flag := FALSE;
END_IF;

IF exit_flag THEN
    found := FALSE;
    // Search for the vehicle to exit
    FOR i := 1 TO 3 DO
        FOR j := 1 TO 5 DO
            IF garage[i, j].VehicleNumber = VehicleNumber_in THEN
                garage[i, j].Occupied := FALSE;
                garage[i, j].VehicleNumber := 0;
                truck.row := i;
                truck.col := j;
                truck.VehicleNumber := VehicleNumber_in;
                found := TRUE;
                EXIT; // Exit inner loop
            END_IF;
        END_FOR;
        IF found THEN
            EXIT; // Exit outer loop
        END_IF;
    END_FOR;
    // Reset exit_flag after processing
    exit_flag := FALSE;
END_IF;

END_FUNCTION_BLOCK