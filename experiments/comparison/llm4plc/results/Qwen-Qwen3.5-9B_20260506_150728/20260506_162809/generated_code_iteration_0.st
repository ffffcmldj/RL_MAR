START_ST
FUNCTION_BLOCK FB_WarehouseManagement
VAR_INPUT 
    requestIn : Bool := FALSE;
    requestOut : Bool := FALSE;
END_VAR

VAR_OUTPUT 
    productNum : Int := 0;
    libFreeNum : Int := 9;
    error : Bool := FALSE;
    status : Word := 16#0000;
END_VAR

VAR_IN_OUT 
    library : Array[1..9] of Bool;
END_VAR

VAR 
    i : INT;
    state : INT := 0; // 0:IDLE, 1:PROCESS_INPUT, 2:PROCESS_OUTPUT, 3:ERROR_FULL, 4:ERROR_EMPTY
    searchIndex : INT;
    found : BOOL;
    errFull : Word := 16#8001;
    errEmpty : Word := 16#8002;
    initDone : Bool := FALSE;
    tempCount : INT;
END_VAR

BEGIN
    (* STATE MACHINE LOGIC *)
    
    CASE state OF
        0: (* STATE 0: IDLE - Initialization & Reset *)
            (* Reset Error Flags *)
            error := FALSE;
            status := 16#0000;
            
            (* Initialization Logic: Run only once if not done *)
            IF NOT initDone THEN
                (* Initialize library array to FALSE (Empty) *)
                searchIndex := 1;
                WHILE searchIndex <= 9 DO
                    library[searchIndex] := FALSE;
                    INC(searchIndex);
                END_WHILE
                
                (* Reset counters to initial state *)
                productNum := 0;
                libFreeNum := 9;
                
                (* Mark initialization as complete *)
                initDone := TRUE;
            END_IF;
            
            (* Transition Logic *)
            (* Check for Storage Full Error *)
            IF requestIn = TRUE AND productNum = 9 THEN
                state := 3; (* ERROR_FULL *)
            (* Check for Storage Empty Error *)
            ELSIF requestOut = TRUE AND productNum = 0 THEN
                state := 4; (* ERROR_EMPTY *)
            (* Check for Valid Input Request *)
            ELSIF requestIn = TRUE AND productNum < 9 THEN
                state := 1; (* PROCESS_INPUT *)
            (* Check for Valid Output Request *)
            ELSIF requestOut = TRUE AND productNum > 0 THEN
                state := 2; (* PROCESS_OUTPUT *)
            END_IF;

        1: (* STATE 1: PROCESS_INPUT - Store Product *)
            (* Search for free position from highest to lowest index *)
            searchIndex := 9;
            found := FALSE;
            
            WHILE searchIndex >= 1 AND NOT found DO
                IF library[searchIndex] = FALSE THEN
                    (* Found free position *)
                    library[searchIndex] := TRUE;
                    productNum := productNum + 1;
                    libFreeNum := libFreeNum - 1;
                    found := TRUE;
                END_IF;
                DEC(searchIndex);
            END_WHILE;
            
            (* If no free slot was found, transition to Error Full *)
            IF NOT found THEN
                error := TRUE;
                status := errFull;
                state := 3; (* ERROR_FULL *)
            ELSE
                (* Successful storage, return to Idle *)
                state := 0;
            END_IF;

        2: (* STATE 2: PROCESS_OUTPUT - Retrieve Product *)
            (* Search for occupied position from lowest to highest index *)
            searchIndex := 1;
            found := FALSE;
            
            WHILE searchIndex <= 9 AND NOT found DO
                IF library[searchIndex] = TRUE THEN
                    (* Found occupied position *)
                    library[searchIndex] := FALSE;
                    productNum := productNum - 1;
                    libFreeNum := libFreeNum + 1;
                    found := TRUE;
                END_IF;
                INC(searchIndex);
            END_WHILE;
            
            (* If no occupied slot was found, transition to Error Empty *)
            IF NOT found THEN
                error := TRUE;
                status := errEmpty;
                state := 4; (* ERROR_EMPTY *)
            ELSE
                (* Successful retrieval, return to Idle *)
                state := 0;
            END_IF;

        3: (* STATE 3: ERROR_FULL *)
            (* Indicate storage full error *)
            error := TRUE;
            status := errFull;
            (* Transition back to Idle in next cycle *)
            state := 0;

        4: (* STATE 4: ERROR_EMPTY *)
            (* Indicate storage empty error *)
            error := TRUE;
            status := errEmpty;
            (* Transition back to Idle in next cycle *)
            state := 0;
            
    ENDCASE
    
END_FUNCTION_BLOCK
END_ST