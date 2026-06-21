TYPE T_TRUCK_INFO :
STRUCT
    row : INT;
    col : INT;
    VehicleNumber : INT;
END_STRUCT
END_TYPE

TYPE T_GARAGE_SLOT :
STRUCT
    Occupied : BOOL;
    VehicleNumber : INT;
END_STRUCT
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
    enter_flag_prev : BOOL;
    exit_flag_prev : BOOL;
    entry_processed : BOOL;
    exit_processed : BOOL;
END_VAR

    // Initialize previous flags
    IF enter_flag_prev = FALSE AND exit_flag_prev = FALSE THEN
        enter_flag_prev := enter_flag;
        exit_flag_prev := exit_flag;
    END_IF;

    // Reset processing flags
    entry_processed := FALSE;
    exit_processed := FALSE;

    // Process exit operation first (priority to free up space)
    IF exit_flag AND NOT exit_flag_prev AND NOT exit_processed THEN
        // Search for occupied slot from row 1 to 3, column 1 to 5
        FOR i := 1 TO 3 DO
            FOR j := 1 TO 5 DO
                IF garage[i, j].Occupied THEN
                    // Found occupied slot - prepare exit information
                    truck.row := i;
                    truck.col := j;
                    truck.VehicleNumber := garage[i, j].VehicleNumber;
                    
                    // Release the parking space
                    garage[i, j].Occupied := FALSE;
                    garage[i, j].VehicleNumber := 0;
                    
                    exit_processed := TRUE;
                    EXIT;
                END_IF;
            END_FOR;
            IF exit_processed THEN
                EXIT;
            END_IF;
        END_FOR;
    END_IF;

    // Process entry operation if exit was not processed
    IF enter_flag AND NOT enter_flag_prev AND NOT entry_processed AND NOT exit_processed THEN
        // Search for available slot from row 3 to 1, column 5 to 1
        FOR i := 3 TO 1 BY -1 DO
            FOR j := 5 TO 1 BY -1 DO
                IF NOT garage[i, j].Occupied THEN
                    // Found available slot - allocate to vehicle
                    garage[i, j].Occupied := TRUE;
                    garage[i, j].VehicleNumber := VehicleNumber_in;
                    
                    entry_processed := TRUE;
                    EXIT;
                END_IF;
            END_FOR;
            IF entry_processed THEN
                EXIT;
            END_IF;
        END_FOR;
    END_IF;

    // Update previous flags for edge detection
    enter_flag_prev := enter_flag;
    exit_flag_prev := exit_flag;

END_FUNCTION_BLOCK