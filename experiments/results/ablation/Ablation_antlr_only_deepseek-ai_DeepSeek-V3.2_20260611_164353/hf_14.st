TYPE T_GARAGE_SLOT:
STRUCT
    Occupied : BOOL;
    VehicleNumber : INT;
END_STRUCT
END_TYPE

TYPE T_TRUCK_INFO:
STRUCT
    row : INT;
    col : INT;
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
    CurrentState : INT := 0;
    NextState : INT := 0;
    EntryFound : BOOL;
    ExitFound : BOOL;
END_VAR

(* State Definitions *)
(* 0: IDLE, 1: ENTRY_PROCESSING, 2: EXIT_PROCESSING *)

(* State Transition *)
CurrentState := NextState;

CASE CurrentState OF
    0: (* IDLE *)
        (* Clear output *)
        truck.row := 0;
        truck.col := 0;
        truck.VehicleNumber := 0;
        EntryFound := FALSE;
        ExitFound := FALSE;
        
        (* Priority: Entry over Exit if both flags are active *)
        IF enter_flag THEN
            NextState := 1; (* Go to ENTRY_PROCESSING *)
        ELSIF exit_flag THEN
            NextState := 2; (* Go to EXIT_PROCESSING *)
        ELSE
            NextState := 0; (* Stay in IDLE *)
        END_IF;
        
    1: (* ENTRY_PROCESSING *)
        (* Search from last row to first, last column to first *)
        i := 3;
        WHILE i >= 1 AND NOT EntryFound DO
            j := 5;
            WHILE j >= 1 AND NOT EntryFound DO
                IF NOT garage[i,j].Occupied THEN
                    (* Allocate space *)
                    garage[i,j].Occupied := TRUE;
                    garage[i,j].VehicleNumber := VehicleNumber_in;
                    EntryFound := TRUE;
                END_IF;
                j := j - 1;
            END_WHILE;
            i := i - 1;
        END_WHILE;
        NextState := 0; (* Always return to IDLE *)
        
    2: (* EXIT_PROCESSING *)
        (* Search from first row to last, first column to last *)
        i := 1;
        WHILE i <= 3 AND NOT ExitFound DO
            j := 1;
            WHILE j <= 5 AND NOT ExitFound DO
                IF garage[i,j].Occupied THEN
                    (* Release space and output info *)
                    truck.row := i;
                    truck.col := j;
                    truck.VehicleNumber := garage[i,j].VehicleNumber;
                    garage[i,j].Occupied := FALSE;
                    garage[i,j].VehicleNumber := 0;
                    ExitFound := TRUE;
                END_IF;
                j := j + 1;
            END_WHILE;
            i := i + 1;
        END_WHILE;
        NextState := 0; (* Always return to IDLE *)
        
    ELSE
        NextState := 0; (* Fallback to IDLE *)
END_CASE;

END_FUNCTION_BLOCK