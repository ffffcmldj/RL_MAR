ructured-text
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
    state : INT; // The state variable to track current state
    prev_Open_CB1_66KV : BOOL; // Previous state of Open_CB1_66KV
    prev_Open_CB2_22KV : BOOL; // Previous state of Open_CB2_22KV
    prev_Open_CB_TRSF1 : BOOL; // Previous state of Open_CB_TRSF1
    Threshold500 : INT := 500; // Constant threshold for fault detection
END_VAR

// STATE 0: INITIALIZE
IF state = 0 THEN
    Short_Circuit_TRSF1 := FALSE;
    Short_Circuit_66BUS := FALSE;
    Open_CB1_66KV := FALSE;
    Open_CB2_66KV := FALSE;
    Open_CB_TRSF1 := FALSE;
    Open_CB2_22KV := FALSE;
    state := 1; // Transition to STATE 1
END_IF

// STATE 1: SHORT CIRCUIT DETECTION
IF state = 1 THEN
    IF Current_Fault_on_TRSF1 > Threshold500 THEN
        Short_Circuit_TRSF1 := TRUE;
    ELSE
        Short_Circuit_TRSF1 := FALSE;
    END_IF;

    IF Current_Fault_on_66BUS1 > Threshold500 THEN
        Short_Circuit_66BUS := TRUE;
    ELSE
        Short_Circuit_66BUS := FALSE;
    END_IF;

    state := 2; // Transition to STATE 2
END_IF

// STATE 2: CIRCUIT BREAKER CONTROL LOGIC
IF state = 2 THEN
    // Open_CB2_22KV Logic
    IF NOT Reset_All_CB AND (NOT prev_Open_CB2_22KV) AND 
       ((Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
        Open_CB2_22KV := TRUE;
    END_IF;

    // Open_CB1_66KV Logic
    IF NOT Reset_All_CB AND (NOT Open_CB2_22KV) AND 
       (prev_Open_CB1_66KV AND Open_CB_TRSF1 OR Short_Circuit_66BUS) THEN
        Open_CB1_66KV := TRUE;
    END_IF;

    // Open_CB_TRSF1 Logic
    IF NOT Reset_All_CB AND (NOT Open_CB2_22KV) AND 
       (Open_CB1_66KV AND prev_Open_CB_TRSF1 OR Short_Circuit_66BUS) THEN
        Open_CB_TRSF1 := TRUE;
    END_IF;

    // Open_CB2_66KV Logic (always TRUE)
    Open_CB2_66KV := TRUE;

    // Update Open_CB2_22KV again
    IF NOT Reset_All_CB AND (NOT prev_Open_CB2_22KV) AND 
       (Open_CB2_66KV AND Open_CB1_66KV AND Open_CB_TRSF1 OR Short_Circuit_TRSF1) THEN
        Open_CB2_22KV := TRUE;
    END_IF;

    // Update Open_CB1_66KV again
    IF NOT Reset_All_CB AND (NOT Open_CB2_22KV) AND 
       (Open_CB2_66KV AND prev_Open_CB1_66KV AND Open_CB_TRSF1 OR Short_Circuit_TRSF1) THEN
        Open_CB1_66KV := TRUE;
    END_IF;

    // Update Open_CB_TRSF1 again
    IF NOT Reset_All_CB AND (NOT Open_CB2_22KV) AND 
       (Open_CB2_66KV AND Open_CB1_66KV AND prev_Open_CB_TRSF1 OR Short_Circuit_TRSF1) THEN
        Open_CB_TRSF1 := TRUE;
    END_IF;

    // Store previous states for next cycle
    prev_Open_CB1_66KV := Open_CB1_66KV;
    prev_Open_CB2_22KV := Open_CB2_22KV;
    prev_Open_CB_TRSF1 := Open_CB_TRSF1;
END_IF

END_FUNCTION_BLOCK
END_ST