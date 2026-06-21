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

// Store previous states at the beginning of each execution
Prev_Open_CB2_22KV := Open_CB2_22KV;
Prev_Open_CB1_66KV := Open_CB1_66KV;
Prev_Open_CB_TRSF1 := Open_CB_TRSF1;

// Step a: Implement short circuit detection
Short_Circuit_66BUS := Current_Fault_on_66BUS1 > Threshold500;
Short_Circuit_TRSF1 := Current_Fault_on_TRSF1 > Threshold500;

// Step b: Implement circuit breaker control logic

// Initialize temporary variables with current values
Temp_Open_CB2_22KV := Open_CB2_22KV;
Temp_Open_CB1_66KV := Open_CB1_66KV;
Temp_Open_CB_TRSF1 := Open_CB_TRSF1;

// First evaluation of Open_CB2_22KV
IF NOT Reset_All_CB AND NOT Prev_Open_CB2_22KV THEN
    IF (Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS THEN
        Temp_Open_CB2_22KV := TRUE;
    END_IF;
ELSE
    Temp_Open_CB2_22KV := FALSE;
END_IF;

// First evaluation of Open_CB1_66KV
IF NOT Reset_All_CB AND NOT Temp_Open_CB2_22KV THEN
    IF (Prev_Open_CB1_66KV AND Open_CB_TRSF1) OR Short_Circuit_66BUS THEN
        Temp_Open_CB1_66KV := TRUE;
    END_IF;
ELSE
    Temp_Open_CB1_66KV := FALSE;
END_IF;

// First evaluation of Open_CB_TRSF1
IF NOT Reset_All_CB AND NOT Temp_Open_CB2_22KV THEN
    IF (Temp_Open_CB1_66KV AND Prev_Open_CB_TRSF1) OR Short_Circuit_66BUS THEN
        Temp_Open_CB_TRSF1 := TRUE;
    END_IF;
ELSE
    Temp_Open_CB_TRSF1 := FALSE;
END_IF;

// Open_CB2_66KV is always TRUE
Open_CB2_66KV := TRUE;

// Update Open_CB2_22KV again (second evaluation)
IF NOT Reset_All_CB AND NOT Prev_Open_CB2_22KV THEN
    IF (Open_CB2_66KV AND Temp_Open_CB1_66KV AND Temp_Open_CB_TRSF1) OR Short_Circuit_TRSF1 THEN
        Temp_Open_CB2_22KV := TRUE;
    END_IF;
ELSE
    Temp_Open_CB2_22KV := FALSE;
END_IF;

// Update Open_CB1_66KV again (second evaluation)
IF NOT Reset_All_CB AND NOT Temp_Open_CB2_22KV THEN
    IF (Open_CB2_66KV AND Prev_Open_CB1_66KV AND Temp_Open_CB_TRSF1) OR Short_Circuit_TRSF1 THEN
        Temp_Open_CB1_66KV := TRUE;
    END_IF;
ELSE
    Temp_Open_CB1_66KV := FALSE;
END_IF;

// Update Open_CB_TRSF1 again (second evaluation)
IF NOT Reset_All_CB AND NOT Temp_Open_CB2_22KV THEN
    IF (Open_CB2_66KV AND Temp_Open_CB1_66KV AND Prev_Open_CB_TRSF1) OR Short_Circuit_TRSF1 THEN
        Temp_Open_CB_TRSF1 := TRUE;
    END_IF;
ELSE
    Temp_Open_CB_TRSF1 := FALSE;
END_IF;

// Apply the temporary values to the actual outputs
Open_CB2_22KV := Temp_Open_CB2_22KV;
Open_CB1_66KV := Temp_Open_CB1_66KV;
Open_CB_TRSF1 := Temp_Open_CB_TRSF1;

// Failsafe: If Reset_All_CB is TRUE, force all breakers to closed (FALSE) state
IF Reset_All_CB THEN
    Open_CB1_66KV := FALSE;
    Open_CB2_66KV := FALSE;
    Open_CB_TRSF1 := FALSE;
    Open_CB2_22KV := FALSE;
END_IF;

END_FUNCTION_BLOCK