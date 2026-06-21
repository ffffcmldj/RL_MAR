START_ST
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
    state : INT; (* 0=IDLE, 1=ENTRY_ALLOCATION, 2=ENTRY_UPDATE, 3=EXIT_SEARCH, 4=EXIT_UPDATE *)
    prevState : INT;
    i : INT;
    j : INT;
    searchComplete : BOOL;
    vehicleFound : BOOL;
    tempVehicleNumber : INT;
    storedVehicleNumber : INT;
    enter_flag_prev : BOOL;
    exit_flag_prev : BOOL;
    enter_request : BOOL;
    exit_request : BOOL;
END_VAR

(* Edge detection for entry and exit flags *)
enter_request := enter_flag AND NOT enter_flag_prev;
exit_request := exit_flag AND NOT exit_flag_prev;
enter_flag_prev := enter_flag;
exit_flag_prev := exit_flag;

(* Main State Machine *)
CASE state OF
    0: (* IDLE *)
        (* Reset search indices based on next operation *)
        IF enter_request THEN
            state := 1;
            storedVehicleNumber := VehicleNumber_in;
            i := 3;
            j := 5;
            searchComplete := FALSE;
        ELSIF exit_request THEN
            state := 3;
            storedVehicleNumber := VehicleNumber_in;
            i := 1;
            j := 1;
            searchComplete := FALSE;
            vehicleFound := FALSE;
        END_IF;
        prevState := state;

    1: (* ENTRY_ALLOCATION *)
        IF NOT searchComplete THEN
            IF (i >= 1) AND (i <= 3) AND (j >= 1) AND (j <= 5) THEN
                IF NOT garage[i, j].Occupied THEN
                    state := 2; (* Free space found *)
                ELSE
                    (* Decrement column *)
                    j := j - 1;
                    IF j < 1 THEN
                        j := 5;
                        i := i - 1; (* Move to previous row *)
                    END_IF;
                    IF i < 1 THEN
                        searchComplete := TRUE; (* No space found *)
                    END_IF;
                END_IF;
            ELSE
                searchComplete := TRUE; (* Indices out of bounds *)
            END_IF;
        ELSE
            state := 0; (* No space found, return to IDLE *)
        END_IF;

    2: (* ENTRY_UPDATE *)
        garage[i, j].Occupied := TRUE;
        garage[i, j].VehicleNumber := storedVehicleNumber;
        state := 0;

    3: (* EXIT_SEARCH *)
        IF NOT searchComplete THEN
            IF (i >= 1) AND (i <= 3) AND (j >= 1) AND (j <= 5) THEN
                IF garage[i, j].Occupied AND (garage[i, j].VehicleNumber = storedVehicleNumber) THEN
                    vehicleFound := TRUE;
                    tempVehicleNumber := garage[i, j].VehicleNumber;
                    state := 4; (* Vehicle found *)
                ELSE
                    (* Increment column *)
                    j := j + 1;
                    IF j > 5 THEN
                        j := 1;
                        i := i + 1; (* Move to next row *)
                    END_IF;
                    IF i > 3 THEN
                        searchComplete := TRUE; (* Vehicle not found *)
                    END_IF;
                END_IF;
            ELSE
                searchComplete := TRUE; (* Indices out of bounds *)
            END_IF;
        ELSE
            state := 0; (* Vehicle not found, return to IDLE *)
        END_IF;

    4: (* EXIT_UPDATE *)
        garage[i, j].Occupied := FALSE;
        garage[i, j].VehicleNumber := 0;
        truck.row := i;
        truck.col := j;
        truck.VehicleNumber := tempVehicleNumber;
        state := 0;

END_CASE;

END_FUNCTION_BLOCK
END_ST