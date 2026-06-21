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
        Previous_Open_CB1_66KV : BOOL := FALSE;
        Previous_Open_CB_TRSF1 : BOOL := FALSE;
        Previous_Open_CB2_22KV : BOOL := FALSE;
        Threshold500 : INT := 500;
    END_VAR

    // Short Circuit Detection
    Short_Circuit_66BUS := Current_Fault_on_66BUS1 > Threshold500;
    Short_Circuit_TRSF1 := Current_Fault_on_TRSF1 > Threshold500;

    // Circuit Breaker Control Logic
    // Initial evaluation of Open_CB2_22KV
    IF NOT Reset_All_CB AND NOT Previous_Open_CB2_22KV THEN
        IF (Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS THEN
            Open_CB2_22KV := TRUE;
        END_IF
    END_IF

    // Initial evaluation of Open_CB1_66KV
    IF NOT Reset_All_CB AND NOT Open_CB2_22KV THEN
        IF (Previous_Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS THEN
            Open_CB1_66KV := TRUE;
        END_IF
    END_IF

    // Initial evaluation of Open_CB_TRSF1
    IF NOT Reset_All_CB AND NOT Open_CB2_22KV THEN
        IF (Open_CB1_66KV AND Previous_Open_CB_TRSF1) OR Short_Circuit_66BUS THEN
            Open_CB_TRSF1 := TRUE;
        END_IF
    END_IF

    // Open_CB2_66KV is always TRUE
    Open_CB2_66KV := TRUE;

    // Update Open_CB2_22KV again
    IF NOT Reset_All_CB AND NOT Previous_Open_CB2_22KV THEN
        IF Open_CB2_66KV AND Open_CB1_66KV AND Open_CB_TRSF1 OR Short_Circuit_TRSF1 THEN
            Open_CB2_22KV := TRUE;
        END_IF
    END_IF

    // Update Open_CB1_66KV again
    IF NOT Reset_All_CB AND NOT Open_CB2_22KV THEN
        IF Open_CB2_66KV AND Previous_Open_CB1_66KV AND Open_CB_TRSF1 OR Short_Circuit_TRSF1 THEN
            Open_CB1_66KV := TRUE;
        END_IF
    END_IF

    // Update Open_CB_TRSF1 again
    IF NOT Reset_All_CB AND NOT Open_CB2_22KV THEN
        IF Open_CB2_66KV AND Open_CB1_66KV AND Previous_Open_CB_TRSF1 OR Short_Circuit_TRSF1 THEN
            Open_CB_TRSF1 := TRUE;
        END_IF
    END_IF

    // Update previous states for next cycle
    Previous_Open_CB1_66KV := Open_CB1_66KV;
    Previous_Open_CB_TRSF1 := Open_CB_TRSF1;
    Previous_Open_CB2_22KV := Open_CB2_22KV;
END_FUNCTION_BLOCK