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

(* a) Implement short circuit detection *)
Short_Circuit_66BUS := (Current_Fault_on_66BUS1 > Threshold500);
Short_Circuit_TRSF1 := (Current_Fault_on_TRSF1 > Threshold500);

(* b) Implement circuit breaker control logic *)

(* First pass: Initial calculations *)
Temp_Open_CB2_22KV := (NOT Reset_All_CB) AND (NOT Prev_Open_CB2_22KV) AND (
    (Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS
);

Temp_Open_CB1_66KV := (NOT Reset_All_CB) AND (NOT Temp_Open_CB2_22KV) AND (
    (Prev_Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS
);

Temp_Open_CB_TRSF1 := (NOT Reset_All_CB) AND (NOT Temp_Open_CB2_22KV) AND (
    (Temp_Open_CB1_66KV AND Prev_Open_CB_TRSF1) OR Short_Circuit_66BUS
);

Open_CB2_66KV := TRUE;

(* Second pass: Update based on new conditions *)
Temp_Open_CB2_22KV := Temp_Open_CB2_22KV OR (
    (NOT Reset_All_CB) AND (NOT Prev_Open_CB2_22KV) AND (
        (Open_CB2_66KV AND Temp_Open_CB1_66KV AND Temp_Open_CB_TRSF1) OR Short_Circuit_TRSF1
    )
);

Temp_Open_CB1_66KV := Temp_Open_CB1_66KV OR (
    (NOT Reset_All_CB) AND (NOT Temp_Open_CB2_22KV) AND (
        (Open_CB2_66KV AND Prev_Open_CB1_66KV AND Temp_Open_CB_TRSF1) OR Short_Circuit_TRSF1
    )
);

Temp_Open_CB_TRSF1 := Temp_Open_CB_TRSF1 OR (
    (NOT Reset_All_CB) AND (NOT Temp_Open_CB2_22KV) AND (
        (Open_CB2_66KV AND Temp_Open_CB1_66KV AND Prev_Open_CB_TRSF1) OR Short_Circuit_TRSF1
    )
);

(* Assign temporary values to outputs *)
Open_CB2_22KV := Temp_Open_CB2_22KV;
Open_CB1_66KV := Temp_Open_CB1_66KV;
Open_CB_TRSF1 := Temp_Open_CB_TRSF1;

(* Store previous states for next scan *)
Prev_Open_CB2_22KV := Open_CB2_22KV;
Prev_Open_CB1_66KV := Open_CB1_66KV;
Prev_Open_CB_TRSF1 := Open_CB_TRSF1;

(* Failsafe: If Reset_All_CB is TRUE, force all circuit breakers to FALSE *)
IF Reset_All_CB THEN
    Open_CB1_66KV := FALSE;
    Open_CB2_66KV := FALSE;
    Open_CB_TRSF1 := FALSE;
    Open_CB2_22KV := FALSE;
    Prev_Open_CB2_22KV := FALSE;
    Prev_Open_CB1_66KV := FALSE;
    Prev_Open_CB_TRSF1 := FALSE;
END_IF;

END_FUNCTION_BLOCK