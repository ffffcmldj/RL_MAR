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
Short_Circuit_66BUS := Current_Fault_on_66BUS1 > Threshold500;
Short_Circuit_TRSF1 := Current_Fault_on_TRSF1 > Threshold500;

(* Set Open_CB2_66KV to TRUE as specified *)
Open_CB2_66KV := TRUE;

(* Reset logic - when Reset_All_CB is TRUE, close all breakers and reset previous states *)
IF Reset_All_CB THEN
    Open_CB2_22KV := FALSE;
    Open_CB1_66KV := FALSE;
    Open_CB_TRSF1 := FALSE;
    Prev_Open_CB2_22KV := FALSE;
    Prev_Open_CB1_66KV := FALSE;
    Prev_Open_CB_TRSF1 := FALSE;
ELSE
    (* First calculation of breaker states *)
    Temp_Open_CB2_22KV := (NOT Prev_Open_CB2_22KV) AND ((Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS);
    Temp_Open_CB1_66KV := (NOT Temp_Open_CB2_22KV) AND ((Prev_Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS);
    Temp_Open_CB_TRSF1 := (NOT Temp_Open_CB2_22KV) AND ((Open_CB1_66KV AND Prev_Open_CB_TRSF1) OR Short_Circuit_66BUS);
    
    (* Update with Open_CB2_66KV and Short_Circuit_TRSF1 conditions *)
    Temp_Open_CB2_22KV := (NOT Prev_Open_CB2_22KV) AND ((Open_CB2_66KV AND Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_TRSF1);
    Temp_Open_CB1_66KV := (NOT Temp_Open_CB2_22KV) AND ((Open_CB2_66KV AND Prev_Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_TRSF1);
    Temp_Open_CB_TRSF1 := (NOT Temp_Open_CB2_22KV) AND ((Open_CB2_66KV AND Open_CB1_66KV AND Prev_Open_CB_TRSF1) OR Short_Circuit_TRSF1);
    
    (* Assign final values to outputs *)
    Open_CB2_22KV := Temp_Open_CB2_22KV;
    Open_CB1_66KV := Temp_Open_CB1_66KV;
    Open_CB_TRSF1 := Temp_Open_CB_TRSF1;
    
    (* Store current states as previous for next scan *)
    Prev_Open_CB2_22KV := Open_CB2_22KV;
    Prev_Open_CB1_66KV := Open_CB1_66KV;
    Prev_Open_CB_TRSF1 := Open_CB_TRSF1;
END_IF;

END_FUNCTION_BLOCK;