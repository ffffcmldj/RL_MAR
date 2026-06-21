START_ST
FUNCTION_BLOCK FB_CircuitControl
VAR_INPUT
    Reset_All_CB : BOOL;
    Current_Fault_on_TRSF1 : INT;
    Current_Fault_on_66BUS1 : INT;
END_VAR

VAR_OUTPUT
    Short_Circuit_TRSF1 : BOOL;
    Short_Circuit_66BUS : BOOL;
    Open_CB1_66KV : BOOL;
    Open_CB2_66KV : BOOL;
    Open_CB_TRSF1 : BOOL;
    Open_CB2_22KV : BOOL;
END_VAR

VAR
    Threshold500 : INT := 500;
    Prev_Open_CB2_22KV : BOOL;
    Prev_Open_CB1_66KV : BOOL;
    Prev_Open_CB_TRSF1 : BOOL;
    Temp_Open_CB2_22KV : BOOL;
    Temp_Open_CB1_66KV : BOOL;
    Temp_Open_CB_TRSF1 : BOOL;
    Temp_Open_CB2_66KV : BOOL;
END_VAR

    (* Short circuit detection - evaluated first *)
    Short_Circuit_66BUS := (Current_Fault_on_66BUS1 > Threshold500);
    Short_Circuit_TRSF1 := (Current_Fault_on_TRSF1 > Threshold500);

    (* Apply reset: if Reset_All_CB is TRUE, close all breakers and skip opening logic *)
    IF Reset_All_CB THEN
        Open_CB2_22KV := FALSE;
        Open_CB1_66KV := FALSE;
        Open_CB_TRSF1 := FALSE;
        Open_CB2_66KV := FALSE;
    ELSE
        (* Step 1: Initial setting of Open_CB2_22KV *)
        Temp_Open_CB2_22KV := Open_CB2_22KV; (* Start with current value *)
        IF (NOT Prev_Open_CB2_22KV) AND 
           ((Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
            Temp_Open_CB2_22KV := TRUE;
        END_IF;

        (* Step 2: Initial setting of Open_CB1_66KV *)
        Temp_Open_CB1_66KV := Open_CB1_66KV; (* Start with current value *)
        IF (NOT Temp_Open_CB2_22KV) AND 
           ((Prev_Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
            Temp_Open_CB1_66KV := TRUE;
        END_IF;

        (* Step 3: Initial setting of Open_CB_TRSF1 *)
        Temp_Open_CB_TRSF1 := Open_CB_TRSF1; (* Start with current value *)
        IF (NOT Temp_Open_CB2_22KV) AND 
           ((Temp_Open_CB1_66KV AND Prev_Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
            Temp_Open_CB_TRSF1 := TRUE;
        END_IF;

        (* Step 4: Open_CB2_66KV always TRUE *)
        Temp_Open_CB2_66KV := TRUE;

        (* Step 5: Update Open_CB2_22KV again *)
        IF (NOT Prev_Open_CB2_22KV) AND 
           ((Temp_Open_CB2_66KV AND Temp_Open_CB1_66KV AND Temp_Open_CB_TRSF1) OR Short_Circuit_TRSF1) THEN
            Temp_Open_CB2_22KV := TRUE;
        END_IF;

        (* Step 6: Update Open_CB1_66KV again *)
        IF (NOT Temp_Open_CB2_22KV) AND 
           ((Temp_Open_CB2_66KV AND Prev_Open_CB1_66KV AND Temp_Open_CB_TRSF1) OR Short_Circuit_TRSF1) THEN
            Temp_Open_CB1_66KV := TRUE;
        END_IF;

        (* Step 7: Update Open_CB_TRSF1 again *)
        IF (NOT Temp_Open_CB2_22KV) AND 
           ((Temp_Open_CB2_66KV AND Temp_Open_CB1_66KV AND Prev_Open_CB_TRSF1) OR Short_Circuit_TRSF1) THEN
            Temp_Open_CB_TRSF1 := TRUE;
        END_IF;

        (* Assign temporary values to outputs *)
        Open_CB2_22KV := Temp_Open_CB2_22KV;
        Open_CB1_66KV := Temp_Open_CB1_66KV;
        Open_CB_TRSF1 := Temp_Open_CB_TRSF1;
        Open_CB2_66KV := Temp_Open_CB2_66KV;
    END_IF;

    (* Store current output states as previous states for the next cycle *)
    Prev_Open_CB2_22KV := Open_CB2_22KV;
    Prev_Open_CB1_66KV := Open_CB1_66KV;
    Prev_Open_CB_TRSF1 := Open_CB_TRSF1;

END_FUNCTION_BLOCK
END_ST