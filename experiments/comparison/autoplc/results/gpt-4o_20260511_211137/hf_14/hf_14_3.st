TYPE T_GARAGE_SLOT :
STRUCT
    Occupied : BOOL;
    VehicleNumber : INT;
END_STRUCT;
END_TYPE

TYPE T_TRUCK_INFO :
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

// Entry Processing State
IF enter_flag THEN
    found := FALSE;
    // Allocate parking space from last row to first row, last column to first column
    FOR i := 3 TO 1 BY -1 DO
        FOR j := 5 TO 1 BY -1 DO
            IF NOT garage[i, j].Occupied THEN
                garage[i, j].Occupied := TRUE;
                garage[i, j].VehicleNumber := VehicleNumber_in;
                found := TRUE;
                EXIT; // Exit the inner loop
            END_IF
        END_FOR
        IF found THEN
            EXIT; // Exit the outer loop
        END_IF
    END_FOR
END_IF

// Exit Processing State
IF exit_flag THEN
    found := FALSE;
    // Release parking space from first row to last row, first column to last column
    FOR i := 1 TO 3 DO
        FOR j := 1 TO 5 DO
            IF garage[i, j].Occupied THEN
                // Populate truck output with the exiting vehicle's information
                truck.row := i;
                truck.col := j;
                truck.VehicleNumber := garage[i, j].VehicleNumber;
                
                // Release the parking space
                garage[i, j].Occupied := FALSE;
                garage[i, j].VehicleNumber := 0;
                found := TRUE;
                EXIT; // Exit the inner loop
            END_IF
        END_FOR
        IF found THEN
            EXIT; // Exit the outer loop
        END_IF
    END_FOR
END_IF

END_FUNCTION_BLOCK