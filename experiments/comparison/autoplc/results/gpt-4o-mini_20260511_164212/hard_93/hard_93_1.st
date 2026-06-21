FUNCTION_BLOCK FB_CircuitControl
VAR_INPUT
    Reset_All_CB : BOOL; // Reset signal for all circuit breakers
    Current_Fault_on_TRSF1 : INT; // Fault current on Transformer 1
    Current_Fault_on_66BUS1 : INT; // Fault current on 66kV Bus 1
END_VAR

VAR_OUTPUT
    Short_Circuit_TRSF1 : BOOL; // Short circuit detection on Transformer 1
    Short_Circuit_66BUS : BOOL; // Short circuit detection on 66kV Bus
    Open_CB1_66KV : BOOL; // Status of Circuit Breaker 1 on 66kV side
    Open_CB2_66KV : BOOL; // Status of Circuit Breaker 2 on 66kV side
    Open_CB_TRSF1 : BOOL; // Status of Circuit Breaker for Transformer 1
    Open_CB2_22KV : BOOL; // Status of Circuit Breaker 2 on 22kV side
END_VAR

VAR
    Threshold500 : INT := 500; // Constant threshold value
    Previous_Open_CB1_66KV : BOOL := FALSE; // Previous state of Open_CB1_66KV
    Previous_Open_CB2_22KV : BOOL := FALSE; // Previous state of Open_CB2_22KV
    Previous_Open_CB_TRSF1 : BOOL := FALSE; // Previous state of Open_CB_TRSF1
END_VAR

// Short Circuit Detection Logic
IF Current_Fault_on_66BUS1 > Threshold500 THEN
    Short_Circuit_66BUS := TRUE;
ELSE
    Short_Circuit_66BUS := FALSE;
END_IF;

IF Current_Fault_on_TRSF1 > Threshold500 THEN
    Short_Circuit_TRSF1 := TRUE;
ELSE
    Short_Circuit_TRSF1 := FALSE;
END_IF;

// Circuit Breaker Control Logic
// Open_CB2_22KV Logic
IF NOT Reset_All_CB THEN
    IF NOT Previous_Open_CB2_22KV THEN
        IF (Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS THEN
            Open_CB2_22KV := TRUE;
        END_IF;
    END_IF;
END_IF;

// Open_CB1_66KV Logic
IF NOT Reset_All_CB THEN
    IF NOT Open_CB2_22KV THEN
        IF (Previous_Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS THEN
            Open_CB1_66KV := TRUE;
        END_IF;
    END_IF;
END_IF;

// Open_CB_TRSF1 Logic
IF NOT Reset_All_CB THEN
    IF NOT Open_CB2_22KV THEN
        IF (Open_CB1_66KV AND Previous_Open_CB_TRSF1) OR Short_Circuit_66BUS THEN
            Open_CB_TRSF1 := TRUE;
        END_IF;
    END_IF;
END_IF;

// Open_CB2_66KV Logic
Open_CB2_66KV := TRUE;

// Update Open_CB2_22KV Logic
IF NOT Reset_All_CB THEN
    IF NOT Previous_Open_CB2_22KV THEN
        IF (Open_CB2_66KV AND Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_TRSF1 THEN
            Open_CB2_22KV := TRUE;
        END_IF;
    END_IF;
END_IF;

// Update Open_CB1_66KV Logic
IF NOT Reset_All_CB THEN
    IF NOT Open_CB2_22KV THEN
        IF (Open_CB2_66KV AND Previous_Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_TRSF1 THEN
            Open_CB1_66KV := TRUE;
        END_IF;
    END_IF;
END_IF;

// Update Open_CB_TRSF1 Logic
IF NOT Reset_All_CB THEN
    IF NOT Open_CB2_22KV THEN
        IF (Open_CB2_66KV AND Open_CB1_66KV AND Previous_Open_CB_TRSF1) OR Short_Circuit_TRSF1 THEN
            Open_CB_TRSF1 := TRUE;
        END_IF;
    END_IF;
END_IF;

// Store previous states for the next cycle
Previous_Open_CB1_66KV := Open_CB1_66KV;
Previous_Open_CB2_22KV := Open_CB2_22KV;
Previous_Open_CB_TRSF1 := Open_CB_TRSF1;

END_FUNCTION_BLOCK