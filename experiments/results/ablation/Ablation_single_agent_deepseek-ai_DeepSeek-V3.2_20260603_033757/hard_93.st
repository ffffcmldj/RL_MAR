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
END_VAR

(* Short Circuit Detection *)
Short_Circuit_66BUS := (Current_Fault_on_66BUS1 > Threshold500);
Short_Circuit_TRSF1 := (Current_Fault_on_TRSF1 > Threshold500);

(* Save previous states for edge detection and logic *)
Prev_Open_CB2_22KV := Open_CB2_22KV;
Prev_Open_CB1_66KV := Open_CB1_66KV;
Prev_Open_CB_TRSF1 := Open_CB_TRSF1;

(* Initial Reset Condition *)
IF Reset_All_CB THEN
    Open_CB2_22KV := FALSE;
    Open_CB1_66KV := FALSE;
    Open_CB_TRSF1 := FALSE;
    Open_CB2_66KV := TRUE;
    RETURN;
END_IF;

(* Step 1: Initial Open_CB2_22KV Logic *)
Temp_Open_CB2_22KV := FALSE;
IF (Prev_Open_CB2_22KV = FALSE) THEN
    IF ((Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
        Temp_Open_CB2_22KV := TRUE;
    END_IF;
END_IF;

(* Step 2: Initial Open_CB1_66KV Logic *)
Temp_Open_CB1_66KV := FALSE;
IF (Temp_Open_CB2_22KV = FALSE) THEN
    IF ((Prev_Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
        Temp_Open_CB1_66KV := TRUE;
    END_IF;
END_IF;

(* Step 3: Initial Open_CB_TRSF1 Logic *)
Temp_Open_CB_TRSF1 := FALSE;
IF (Temp_Open_CB2_22KV = FALSE) THEN
    IF ((Open_CB1_66KV AND Prev_Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
        Temp_Open_CB_TRSF1 := TRUE;
    END_IF;
END_IF;

(* Step 4: Open_CB2_66KV is always TRUE *)
Open_CB2_66KV := TRUE;

(* Step 5: Update Open_CB2_22KV again *)
IF (Prev_Open_CB2_22KV = FALSE) THEN
    IF ((Open_CB2_66KV AND Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_TRSF1) THEN
        Temp_Open_CB2_22KV := TRUE;
    END_IF;
END_IF;

(* Step 6: Update Open_CB1_66KV again *)
IF (Temp_Open_CB2_22KV = FALSE) THEN
    IF ((Open_CB2_66KV AND Prev_Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_TRSF1) THEN
        Temp_Open_CB1_66KV := TRUE;
    END_IF;
END_IF;

(* Step 7: Update Open_CB_TRSF1 again *)
IF (Temp_Open_CB2_22KV = FALSE) THEN
    IF ((Open_CB2_66KV AND Open_CB1_66KV AND Prev_Open_CB_TRSF1) OR Short_Circuit_TRSF1) THEN
        Temp_Open_CB_TRSF1 := TRUE;
    END_IF;
END_IF;

(* Apply final values with anti-rapid switching: only change if new state is TRUE and current is FALSE *)
IF (Temp_Open_CB2_22KV AND (NOT Open_CB2_22KV)) THEN
    Open_CB2_22KV := TRUE;
END_IF;

IF (Temp_Open_CB1_66KV AND (NOT Open_CB1_66KV)) THEN
    Open_CB1_66KV := TRUE;
END_IF;

IF (Temp_Open_CB_TRSF1 AND (NOT Open_CB_TRSF1)) THEN
    Open_CB_TRSF1 := TRUE;
END_IF;

END_FUNCTION_BLOCK