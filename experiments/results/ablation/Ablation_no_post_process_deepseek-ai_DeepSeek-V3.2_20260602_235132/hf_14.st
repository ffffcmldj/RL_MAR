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
    CurrentState : INT; (* 0=IDLE, 1=ENTRY_ALLOCATION, 2=ENTRY_SEARCH, 3=EXIT_SEARCH *)
    i : INT;
    j : INT;
    EntryFound : BOOL;
    ExitFound : BOOL;
END_VAR

(* Main State Machine *)
CASE CurrentState OF
    0: (* IDLE *)
        (* Reset outputs and internal flags *)
        truck.row := 0;
        truck.col := 0;
        truck.VehicleNumber := 0;
        EntryFound := FALSE;
        ExitFound := FALSE;
        
        (* Determine next state based on request priority *)
        IF enter_flag THEN
            CurrentState := 1; (* Proceed to entry allocation *)
        ELSIF exit_flag THEN
            CurrentState := 3; (* Proceed to exit search *)
        ELSE
            CurrentState := 0; (* Remain idle *)
        END_IF;
        
    1: (* ENTRY_ALLOCATION - Initialize search for available space *)
        (* Initialize search indices according to "latter row first, latter column first" *)
        i := 3; (* Start from last row *)
        j := 5; (* Start from last column *)
        CurrentState := 2; (* Proceed to search loop *)
        
    2: (* ENTRY_SEARCH - Find and allocate available parking space *)
        IF (i >= 1) AND (i <= 3) AND (j >= 1) AND (j <= 5) THEN
            IF NOT garage[i, j].Occupied THEN
                (* Found available space - allocate it *)
                garage[i, j].Occupied := TRUE;
                garage[i, j].VehicleNumber := VehicleNumber_in;
                EntryFound := TRUE;
                CurrentState := 0; (* Return to idle *)
            ELSE
                (* Space occupied - move to next position *)
                j := j - 1;
                IF j < 1 THEN
                    (* Move to previous row *)
                    i := i - 1;
                    j := 5;
                    IF i < 1 THEN
                        (* No available spaces found *)
                        CurrentState := 0;
                    END_IF;
                END_IF;
                (* Remain in ENTRY_SEARCH state to continue search *)
            END_IF;
        ELSE
            (* Search indices out of bounds - error recovery *)
            CurrentState := 0;
        END_IF;
        
    3: (* EXIT_SEARCH - Find and release specified vehicle *)
        (* Initialize search if needed *)
        IF (i < 1) OR (i > 3) OR (j < 1) OR (j > 5) THEN
            i := 1; (* Start from first row *)
            j := 1; (* Start from first column *)
        END_IF;
        
        IF (i >= 1) AND (i <= 3) AND (j >= 1) AND (j <= 5) THEN
            IF garage[i, j].Occupied AND (garage[i, j].VehicleNumber = VehicleNumber_in) THEN
                (* Found vehicle to exit - release space *)
                truck.row := i;
                truck.col := j;
                truck.VehicleNumber := VehicleNumber_in;
                garage[i, j].Occupied := FALSE;
                garage[i, j].VehicleNumber := 0;
                ExitFound := TRUE;
                CurrentState := 0; (* Return to idle *)
            ELSE
                (* Not the target vehicle - move to next position *)
                (* Follow "former row first, former column first" for search order *)
                j := j + 1;
                IF j > 5 THEN
                    i := i + 1;
                    j := 1;
                    IF i > 3 THEN
                        (* Vehicle not found in garage *)
                        CurrentState := 0;
                    END_IF;
                END_IF;
                (* Remain in EXIT_SEARCH state to continue search *)
            END_IF;
        ELSE
            (* Search indices out of bounds - error recovery *)
            CurrentState := 0;
        END_IF;
        
    ELSE
        (* Invalid state - reset to IDLE *)
        CurrentState := 0;
END_CASE;

END_FUNCTION_BLOCK