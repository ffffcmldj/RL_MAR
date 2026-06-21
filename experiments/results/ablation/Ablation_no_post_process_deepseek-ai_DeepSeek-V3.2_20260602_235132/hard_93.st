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
    bTemp_Open_CB2_22KV : BOOL;
    bTemp_Open_CB1_66KV : BOOL;
    bTemp_Open_CB_TRSF1 : BOOL;
END_VAR

(* Part a: Short circuit detection *)
Short_Circuit_66BUS := (Current_Fault_on_66BUS1 > Threshold500);
Short_Circuit_TRSF1 := (Current_Fault_on_TRSF1 > Threshold500);

(* Part b: Circuit breaker control logic *)
(* Reset condition takes highest priority *)
IF Reset_All_CB THEN
    Open_CB1_66KV := FALSE;
    Open_CB2_66KV := FALSE;
    Open_CB_TRSF1 := FALSE;
    Open_CB2_22KV := FALSE;
    Prev_Open_CB2_22KV := FALSE;
    Prev_Open_CB1_66KV := FALSE;
    Prev_Open_CB_TRSF1 := FALSE;
ELSE
    (* Open_CB2_66KV is always TRUE (closed) per specification *)
    Open_CB2_66KV := TRUE;
    
    (* First pass: Initial calculations using previous cycle states *)
    bTemp_Open_CB2_22KV := (NOT Prev_Open_CB2_22KV) AND 
                           ((Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS);
    
    bTemp_Open_CB1_66KV := (NOT bTemp_Open_CB2_22KV) AND 
                           ((Prev_Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS);
    
    bTemp_Open_CB_TRSF1 := (NOT bTemp_Open_CB2_22KV) AND 
                           ((Open_CB1_66KV AND Prev_Open_CB_TRSF1) OR Short_Circuit_66BUS);
    
    (* Second pass: Update calculations using intermediate values *)
    bTemp_Open_CB2_22KV := bTemp_Open_CB2_22KV OR 
                          ((NOT Prev_Open_CB2_22KV) AND 
                           ((Open_CB2_66KV AND bTemp_Open_CB1_66KV AND bTemp_Open_CB_TRSF1) OR Short_Circuit_TRSF1));
    
    bTemp_Open_CB1_66KV := bTemp_Open_CB1_66KV OR 
                          ((NOT bTemp_Open_CB2_22KV) AND 
                           ((Open_CB2_66KV AND Prev_Open_CB1_66KV AND bTemp_Open_CB_TRSF1) OR Short_Circuit_TRSF1));
    
    bTemp_Open_CB_TRSF1 := bTemp_Open_CB_TRSF1 OR 
                          ((NOT bTemp_Open_CB2_22KV) AND 
                           ((Open_CB2_66KV AND bTemp_Open_CB1_66KV AND Prev_Open_CB_TRSF1) OR Short_Circuit_TRSF1));
    
    (* Assign final values to outputs *)
    Open_CB2_22KV := bTemp_Open_CB2_22KV;
    Open_CB1_66KV := bTemp_Open_CB1_66KV;
    Open_CB_TRSF1 := bTemp_Open_CB_TRSF1;
    
    (* Store current states for next scan cycle *)
    Prev_Open_CB2_22KV := Open_CB2_22KV;
    Prev_Open_CB1_66KV := Open_CB1_66KV;
    Prev_Open_CB_TRSF1 := Open_CB_TRSF1;
END_IF;

END_FUNCTION_BLOCK;