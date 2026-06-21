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

(* Short circuit detection *)
Short_Circuit_66BUS := (Current_Fault_on_66BUS1 > Threshold500);
Short_Circuit_TRSF1 := (Current_Fault_on_TRSF1 > Threshold500);

(* Store previous states at the beginning of execution cycle *)
Prev_Open_CB2_22KV := Open_CB2_22KV;
Prev_Open_CB1_66KV := Open_CB1_66KV;
Prev_Open_CB_TRSF1 := Open_CB_TRSF1;

(* Initialize temporary variables with current output states *)
Temp_Open_CB2_22KV := Open_CB2_22KV;
Temp_Open_CB1_66KV := Open_CB1_66KV;
Temp_Open_CB_TRSF1 := Open_CB_TRSF1;

(* Reset handling - overrides all other logic *)
IF Reset_All_CB THEN
    Temp_Open_CB2_22KV := FALSE;
    Temp_Open_CB1_66KV := FALSE;
    Temp_Open_CB_TRSF1 := FALSE;
    Open_CB2_66KV := FALSE;  (* Even though spec says always TRUE, reset should override *)
ELSE
    (* First pass of circuit breaker control logic *)
    (* Open_CB2_22KV first condition *)
    IF (NOT Prev_Open_CB2_22KV) AND
       ((Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
        Temp_Open_CB2_22KV := TRUE;
    END_IF;
    
    (* Open_CB1_66KV first condition *)
    IF (NOT Temp_Open_CB2_22KV) AND
       ((Prev_Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
        Temp_Open_CB1_66KV := TRUE;
    END_IF;
    
    (* Open_CB_TRSF1 first condition *)
    IF (NOT Temp_Open_CB2_22KV) AND
       ((Open_CB1_66KV AND Prev_Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
        Temp_Open_CB_TRSF1 := TRUE;
    END_IF;
    
    (* Open_CB2_66KV always TRUE when not reset *)
    Open_CB2_66KV := TRUE;
    
    (* Update Open_CB2_22KV again *)
    IF (NOT Prev_Open_CB2_22KV) AND
       ((Open_CB2_66KV AND Temp_Open_CB1_66KV AND Temp_Open_CB_TRSF1) OR Short_Circuit_TRSF1) THEN
        Temp_Open_CB2_22KV := TRUE;
    END_IF;
    
    (* Update Open_CB1_66KV again *)
    IF (NOT Temp_Open_CB2_22KV) AND
       ((Open_CB2_66KV AND Prev_Open_CB1_66KV AND Temp_Open_CB_TRSF1) OR Short_Circuit_TRSF1) THEN
        Temp_Open_CB1_66KV := TRUE;
    END_IF;
    
    (* Update Open_CB_TRSF1 again *)
    IF (NOT Temp_Open_CB2_22KV) AND
       ((Open_CB2_66KV AND Temp_Open_CB1_66KV AND Prev_Open_CB_TRSF1) OR Short_Circuit_TRSF1) THEN
        Temp_Open_CB_TRSF1 := TRUE;
    END_IF;
END_IF;

(* Apply temporary states to outputs *)
Open_CB2_22KV := Temp_Open_CB2_22KV;
Open_CB1_66KV := Temp_Open_CB1_66KV;
Open_CB_TRSF1 := Temp_Open_CB_TRSF1;

END_FUNCTION_BLOCK