TYPE
    T_TRUCK_INFO : STRUCT
        row : INT;
        col : INT;
        VehicleNumber : INT;
    END_STRUCT;
    T_GARAGE_SLOT : STRUCT
        Occupied : BOOL;
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
found_entry : BOOL;
found_exit : BOOL;
END_VAR

truck.row := 0;
truck.col := 0;
truck.VehicleNumber := 0;
found_entry := FALSE;
found_exit := FALSE;

IF enter_flag = TRUE THEN
    found_entry := FALSE;
    i := 3;
    WHILE i >= 1 AND found_entry = FALSE DO
        j := 5;
        WHILE j >= 1 AND found_entry = FALSE DO
            IF garage[i, j].Occupied = FALSE THEN
                garage[i, j].Occupied := TRUE;
                garage[i, j].VehicleNumber := VehicleNumber_in;
                truck.row := i;
                truck.col := j;
                truck.VehicleNumber := VehicleNumber_in;
                found_entry := TRUE;
            END_IF;
            j := j - 1;
        END_WHILE;
        i := i - 1;
    END_WHILE;
END_IF;

IF exit_flag = TRUE AND found_entry = FALSE THEN
    found_exit := FALSE;
    i := 1;
    WHILE i <= 3 AND found_exit = FALSE DO
        j := 1;
        WHILE j <= 5 AND found_exit = FALSE DO
            IF garage[i, j].Occupied = TRUE THEN
                truck.row := i;
                truck.col := j;
                truck.VehicleNumber := garage[i, j].VehicleNumber;
                garage[i, j].Occupied := FALSE;
                garage[i, j].VehicleNumber := 0;
                found_exit := TRUE;
            END_IF;
            j := j + 1;
        END_WHILE;
        i := i + 1;
    END_WHILE;
END_IF;

END_FUNCTION_BLOCK