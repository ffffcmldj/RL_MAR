FUNCTION_BLOCK TruckGarage
VAR_INPUT
    enter_flag : BOOL;
    exit_flag : BOOL;
    VehicleNumber_in : INT;
END_VAR
VAR_OUTPUT
    truck_row : INT;
    truck_col : INT;
    truck_VehicleNumber : INT;
END_VAR
VAR_IN_OUT
    garage : ARRAY[1..3, 1..5] OF STRUCT
        Occupied : BOOL;
        VehicleNumber : INT;
    END_STRUCT;
END_VAR
VAR
    i : INT;
    j : INT;
    found : BOOL;
END_VAR

// Entry logic
IF enter_flag THEN
    found := FALSE;
    
    // Search from last row to first, last column to first
    FOR i := 3 TO 1 BY -1 DO
        FOR j := 5 TO 1 BY -1 DO
            IF NOT garage[i, j].Occupied AND NOT found THEN
                // Found empty spot
                garage[i, j].Occupied := TRUE;
                garage[i, j].VehicleNumber := VehicleNumber_in;
                found := TRUE;
            END_IF
        END_FOR
    END_FOR
END_IF

// Exit logic
IF exit_flag THEN
    found := FALSE;
    
    // Search from first row to last, first column to last
    FOR i := 1 TO 3 DO
        FOR j := 1 TO 5 DO
            IF garage[i, j].Occupied AND garage[i, j].VehicleNumber = VehicleNumber_in AND NOT found THEN
                // Found vehicle to exit
                truck_row := i;
                truck_col := j;
                truck_VehicleNumber := garage[i, j].VehicleNumber;
                
                // Clear the parking spot
                garage[i, j].Occupied := FALSE;
                garage[i, j].VehicleNumber := 0;
                found := TRUE;
            END_IF
        END_FOR
    END_FOR
    
    // If vehicle not found, clear output
    IF NOT found THEN
        truck_row := 0;
        truck_col := 0;
        truck_VehicleNumber := 0;
    END_IF
END_IF

// Clear outputs when no operation
IF NOT enter_flag AND NOT exit_flag THEN
    truck_row := 0;
    truck_col := 0;
    truck_VehicleNumber := 0;
END_IF
END_FUNCTION_BLOCK