iec61131-3
START_ST
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
    state : INT; // Current state variable
    prevState : INT; // Previous state variable
    Threshold500 : INT := 500; // Constant threshold value for short circuit detection
    prev_Open_CB2_22KV : BOOL; // Previous state of Open_CB2_22KV
    prev_Open_CB1_66KV : BOOL; // Previous state of Open_CB1_66KV
    prev_Open_CB_TRSF1 : BOOL; // Previous state of Open_CB_TRSF1
END_VAR

// Initialize default states
IF state = 0 THEN
    Short_Circuit_TRSF1 := FALSE;
    Short_Circuit_66BUS := FALSE;
    Open_CB1_66KV := FALSE;
    Open_CB2_66KV := TRUE; // Default state
    Open_CB_TRSF1 := FALSE;
    Open_CB2_22KV := FALSE;
    prev_Open_CB2_22KV := FALSE;
    prev_Open_CB1_66KV := FALSE;
    prev_Open_CB_TRSF1 := FALSE;
    state := 1; // Transition to short circuit detection state
END_IF

// Short circuit detection
IF state = 1 THEN
    Short_Circuit_TRSF1 := Current_Fault_on_TRSF1 > Threshold500;
    Short_Circuit_66BUS := Current_Fault_on_66BUS1 > Threshold500;
    state := 2; // Transition to circuit breaker control logic - first pass
END_IF

// Circuit breaker control logic - first pass
IF state = 2 THEN
    // Open_CB2_22KV logic
    IF NOT Reset_All_CB AND NOT prev_Open_CB2_22KV AND 
       ((Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
        Open_CB2_22KV := TRUE;
    ELSE
        Open_CB2_22KV := FALSE;
    END_IF

    // Open_CB1_66KV logic
    IF NOT Reset_All_CB AND NOT Open_CB2_22KV AND 
       ((prev_Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
        Open_CB1_66KV := TRUE;
    ELSE
        Open_CB1_66KV := FALSE;
    END_IF

    // Open_CB_TRSF1 logic
    IF NOT Reset_All_CB AND NOT Open_CB2_22KV AND 
       ((Open_CB1_66KV AND prev_Open_CB_TRSF1) OR Short_Circuit_66BUS) THEN
        Open_CB_TRSF1 := TRUE;
    ELSE
        Open_CB_TRSF1 := FALSE;
    END_IF

    state := 3; // Transition to circuit breaker control logic - second pass
END_IF

// Circuit breaker control logic - second pass
IF state = 3 THEN
    // Open_CB2_22KV logic update
    IF NOT Reset_All_CB AND NOT prev_Open_CB2_22KV AND 
       ((Open_CB2_66KV AND Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_TRSF1) THEN
        Open_CB2_22KV := TRUE;
    ELSE
        Open_CB2_22KV := FALSE;
    END_IF

    // Open_CB1_66KV logic update
    IF NOT Reset_All_CB AND NOT Open_CB2_22KV AND 
       ((Open_CB2_66KV AND prev_Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_TRSF1) THEN
        Open_CB1_66KV := TRUE;
    ELSE
        Open_CB1_66KV := FALSE;
    END_IF

    // Open_CB_TRSF1 logic update
    IF NOT Reset_All_CB AND NOT Open_CB2_22KV AND 
       ((Open_CB2_66KV AND Open_CB1_66KV AND prev_Open_CB_TRSF1) OR Short_Circuit_TRSF1) THEN
        Open_CB_TRSF1 := TRUE;
    ELSE
        Open_CB_TRSF1 := FALSE;
    END_IF

    // Always set Open_CB2_66KV to TRUE
    Open_CB2_66KV := TRUE;

    // Transition back to initialization state if Reset_All_CB is TRUE
    IF Reset_All_CB THEN
        state := 0;
    END_IF
END_IF

// Update previous states for next scan cycle
prev_Open_CB2_22KV := Open_CB2_22KV;
prev_Open_CB1_66KV := Open_CB1_66KV;
prev_Open_CB_TRSF1 := Open_CB_TRSF1;

END_FUNCTION_BLOCK
END_ST