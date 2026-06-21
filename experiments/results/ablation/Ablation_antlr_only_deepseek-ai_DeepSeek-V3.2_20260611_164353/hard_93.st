TYPE ST_CircuitBreakerStates :
STRUCT
    Open_CB2_22KV : BOOL;
    Open_CB1_66KV : BOOL;
    Open_CB_TRSF1 : BOOL;
    Open_CB2_66KV : BOOL;
END_STRUCT
END_TYPE

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
    Prev_States : ST_CircuitBreakerStates;
    Next_States : ST_CircuitBreakerStates;
    bShortCircuitDetected : BOOL;
END_VAR

(* 1. SHORT CIRCUIT DETECTION (Independent of Reset) *)
Short_Circuit_66BUS := (Current_Fault_on_66BUS1 > Threshold500);
Short_Circuit_TRSF1 := (Current_Fault_on_TRSF1 > Threshold500);

(* 2. RESET OVERRIDE - All breakers to FALSE (Closed) except CB2_66KV *)
IF Reset_All_CB THEN
    Next_States.Open_CB2_22KV := FALSE;
    Next_States.Open_CB1_66KV := FALSE;
    Next_States.Open_CB_TRSF1 := FALSE;
    Next_States.Open_CB2_66KV := TRUE; (* Per specification *)
ELSE
    (* 3. CALCULATE NEXT STATES BASED ON PREVIOUS SCAN CYCLE *)
    (* Initialize with previous state - prevents rapid switching *)
    Next_States := Prev_States;
    
    (* Combined short circuit flag for logic simplification *)
    bShortCircuitDetected := Short_Circuit_66BUS OR Short_Circuit_TRSF1;
    
    (* --- FIRST PASS LOGIC (as per specification order) --- *)
    (* Open_CB2_22KV - First Condition *)
    IF (NOT Prev_States.Open_CB2_22KV) AND 
       ((Prev_States.Open_CB1_66KV AND Prev_States.Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
        Next_States.Open_CB2_22KV := TRUE;
    END_IF;
    
    (* Open_CB1_66KV - First Condition *)
    IF (NOT Next_States.Open_CB2_22KV) AND 
       ((Prev_States.Open_CB1_66KV AND Prev_States.Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
        Next_States.Open_CB1_66KV := TRUE;
    END_IF;
    
    (* Open_CB_TRSF1 - First Condition *)
    IF (NOT Next_States.Open_CB2_22KV) AND 
       ((Next_States.Open_CB1_66KV AND Prev_States.Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
        Next_States.Open_CB_TRSF1 := TRUE;
    END_IF;
    
    (* Open_CB2_66KV - Always TRUE per specification *)
    Next_States.Open_CB2_66KV := TRUE;
    
    (* --- SECOND PASS LOGIC (Updates as per specification) --- *)
    (* Update Open_CB2_22KV again *)
    IF (NOT Prev_States.Open_CB2_22KV) AND 
       ((Next_States.Open_CB2_66KV AND Next_States.Open_CB1_66KV AND Next_States.Open_CB_TRSF1) OR Short_Circuit_TRSF1) THEN
        Next_States.Open_CB2_22KV := TRUE;
    END_IF;
    
    (* Update Open_CB1_66KV again *)
    IF (NOT Next_States.Open_CB2_22KV) AND 
       ((Next_States.Open_CB2_66KV AND Prev_States.Open_CB1_66KV AND Next_States.Open_CB_TRSF1) OR Short_Circuit_TRSF1) THEN
        Next_States.Open_CB1_66KV := TRUE;
    END_IF;
    
    (* Update Open_CB_TRSF1 again *)
    IF (NOT Next_States.Open_CB2_22KV) AND 
       ((Next_States.Open_CB2_66KV AND Next_States.Open_CB1_66KV AND Prev_States.Open_CB_TRSF1) OR Short_Circuit_TRSF1) THEN
        Next_States.Open_CB_TRSF1 := TRUE;
    END_IF;
    
    (* 4. FAILSAFE: If any short circuit is detected, ensure critical breakers open *)
    IF bShortCircuitDetected THEN
        Next_States.Open_CB1_66KV := TRUE;
        Next_States.Open_CB_TRSF1 := TRUE;
        Next_States.Open_CB2_22KV := TRUE;
    END_IF;
END_IF;

(* 5. ASSIGN NEXT STATES TO OUTPUTS *)
Open_CB2_22KV := Next_States.Open_CB2_22KV;
Open_CB1_66KV := Next_States.Open_CB1_66KV;
Open_CB_TRSF1 := Next_States.Open_CB_TRSF1;
Open_CB2_66KV := Next_States.Open_CB2_66KV;

(* 6. STORE CURRENT STATES FOR NEXT SCAN CYCLE *)
Prev_States := Next_States;

END_FUNCTION_BLOCK;