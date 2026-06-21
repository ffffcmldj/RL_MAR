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
    // State Machine Variables
    FSM_State : INT := 0; // 0: Detection, 1: Init CB, 2: Update CB, 3: Assign Outputs

    // Previous State Holders (INT: 0=FALSE, 1=TRUE)
    // Mapped from the provided variable list names as per plan instruction
    Prev_Open_CB1_66KV : INT := 0;
    Prev_Open_CB2_66KV : INT := 0;
    Prev_Open_CB_TRSF1 : INT := 0;
    Prev_Open_CB2_22KV : INT := 0;

    // Temporary Logic Variables for intermediate calculations
    Temp_Open_CB2_22KV : BOOL;
    Temp_Open_CB1_66KV : BOOL;
    Temp_Open_CB_TRSF1 : BOOL;
    Temp_Open_CB2_66KV : BOOL;
    Temp_Open_CB2_22KV_Updated : BOOL;
    Temp_Open_CB1_66KV_Updated : BOOL;
    Temp_Open_CB_TRSF1_Updated : BOOL;

    // Constant
    Threshold500 : INT := 500;
END_VAR

BEGIN
    // ---------------------------------------------------------
    // STATE 0: SHORT_CIRCUIT_DETECTION
    // ---------------------------------------------------------
    IF FSM_State = 0 THEN
        // Set Short Circuit flags based on current fault currents
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

        // Transition to State 1
        FSM_State := 1;
    END_IF;

    // ---------------------------------------------------------
    // STATE 1: CB_CONTROL_SEQUENCE_START
    // ---------------------------------------------------------
    IF FSM_State = 1 THEN
        // Logic for Open_CB2_22KV (Initial Pass)
        // Condition: Reset_All_CB is FALSE AND Prev was FALSE AND (Open_CB1_66KV is TRUE AND Open_CB_TRSF1 is TRUE OR Short_Circuit_66BUS is TRUE)
        // Note: Using current output values for dependency as per sequential execution requirement
        IF (NOT Reset_All_CB) AND (Prev_Open_CB2_22KV = 0) AND
           ((Open_CB1_66KV = TRUE) AND (Open_CB_TRSF1 = TRUE) OR Short_Circuit_66BUS = TRUE) THEN
            Temp_Open_CB2_22KV := TRUE;
        ELSE
            Temp_Open_CB2_22KV := FALSE;
        END_IF;

        // Logic for Open_CB1_66KV (Initial Pass)
        // Condition: Reset_All_CB is FALSE AND Open_CB2_22KV is FALSE AND (Prev was TRUE AND Open_CB_TRSF1 is TRUE OR Short_Circuit_66BUS is TRUE)
        // Note: Using Temp_Open_CB2_22KV just calculated
        IF (NOT Reset_All_CB) AND (Temp_Open_CB2_22KV = FALSE) AND
           ((Prev_Open_CB1_66KV = 1) AND (Open_CB_TRSF1 = TRUE) OR Short_Circuit_66BUS = TRUE) THEN
            Temp_Open_CB1_66KV := TRUE;
        ELSE
            Temp_Open_CB1_66KV := FALSE;
        END_IF;

        // Logic for Open_CB_TRSF1 (Initial Pass)
        // Condition: Reset_All_CB is FALSE AND Open_CB2_22KV is FALSE AND (Open_CB1_66KV is TRUE AND Prev was TRUE OR Short_Circuit_66BUS is TRUE)
        // Note: Using Temp_Open_CB1_66KV just calculated
        IF (NOT Reset_All_CB) AND (Temp_Open_CB2_22KV = FALSE) AND
           ((Temp_Open_CB1_66KV = TRUE) AND (Prev_Open_CB_TRSF1 = 1) OR Short_Circuit_66BUS = TRUE) THEN
            Temp_Open_CB_TRSF1 := TRUE;
        ELSE
            Temp_Open_CB_TRSF1 := FALSE;
        END_IF;

        // Open_CB2_66KV: Always set to TRUE (Initial Pass)
        Temp_Open_CB2_66KV := TRUE;

        // Transition to State 2
        FSM_State := 2;
    END_IF;

    // ---------------------------------------------------------
    // STATE 2: CB_CONTROL_SEQUENCE_UPDATE
    // ---------------------------------------------------------
    IF FSM_State = 2 THEN
        // Update Open_CB2_66KV (Conditional Logic)
        // Condition: Reset_All_CB is FALSE AND Prev was FALSE AND (Open_CB2_66KV is TRUE AND Open_CB1_66KV is TRUE AND Open_CB_TRSF1 is TRUE OR Short_Circuit_TRSF1 is TRUE)
        // Note: Using current output values for dependency
        IF (NOT Reset_All_CB) AND (Prev_Open_CB2_66KV = 0) AND
           ((Open_CB2_66KV = TRUE) AND (Open_CB1_66KV = TRUE) AND (Open_CB_TRSF1 = TRUE) OR Short_Circuit_TRSF1 = TRUE) THEN
            Temp_Open_CB2_66KV := TRUE;
        ELSE
            Temp_Open_CB2_66KV := FALSE;
        END_IF;

        // Update Open_CB2_22KV again
        // Condition: Reset_All_CB is FALSE AND Prev was FALSE AND (Open_CB2_66KV is TRUE AND Open_CB1_66KV is TRUE AND Open_CB_TRSF1 is TRUE OR Short_Circuit_TRSF1 is TRUE)
        IF (NOT Reset_All_CB) AND (Prev_Open_CB2_22KV = 0) AND
           ((Temp_Open_CB2_66KV = TRUE) AND (Open_CB1_66KV = TRUE) AND (Open_CB_TRSF1 = TRUE) OR Short_Circuit_TRSF1 = TRUE) THEN
            Temp_Open_CB2_22KV_Updated := TRUE;
        ELSE
            Temp_Open_CB2_22KV_Updated := FALSE;
        END_IF;

        // Update Open_CB1_66KV again
        // Condition: Reset_All_CB is FALSE AND Open_CB2_22KV is FALSE AND (Open_CB2_66KV is TRUE AND Prev was TRUE AND Open_CB_TRSF1 is TRUE OR Short_Circuit_TRSF1 is TRUE)
        IF (NOT Reset_All_CB) AND (Temp_Open_CB2_22KV_Updated = FALSE) AND
           ((Temp_Open_CB2_66KV = TRUE) AND (Prev_Open_CB1_66KV = 1) AND (Open_CB_TRSF1 = TRUE) OR Short_Circuit_TRSF1 = TRUE) THEN
            Temp_Open_CB1_66KV_Updated := TRUE;
        ELSE
            Temp_Open_CB1_66KV_Updated := FALSE;
        END_IF;

        // Update Open_CB_TRSF1 again
        // Condition: Reset_All_CB is FALSE AND Open_CB2_22KV is FALSE AND (Open_CB2_66KV is TRUE AND Open_CB1_66KV is TRUE AND Prev was TRUE OR Short_Circuit_TRSF1 is TRUE)
        IF (NOT Reset_All_CB) AND (Temp_Open_CB2_22KV_Updated = FALSE) AND
           ((Temp_Open_CB2_66KV = TRUE) AND (Temp_Open_CB1_66KV_Updated = TRUE) AND (Prev_Open_CB_TRSF1 = 1) OR Short_Circuit_TRSF1 = TRUE) THEN
            Temp_Open_CB_TRSF1_Updated := TRUE;
        ELSE
            Temp_Open_CB_TRSF1_Updated := FALSE;
        END_IF;

        // Transition to State 3
        FSM_State := 3;
    END_IF;

    // ---------------------------------------------------------
    // STATE 3: STATE_HOLD / OUTPUT_ASSIGNMENT
    // ---------------------------------------------------------
    IF FSM_State = 3 THEN
        // Assign calculated values to Output variables
        Open_CB2_22KV := Temp_Open_CB2_22KV_Updated;
        Open_CB1_66KV := Temp_Open_CB1_66KV_Updated;
        Open_CB_TRSF1 := Temp_Open_CB_TRSF1_Updated;
        Open_CB2_66KV := Temp_Open_CB2_66KV;

        // Update Previous State Holders (INT) for next cycle
        // 0 for FALSE, 1 for TRUE
        Prev_Open_CB2_22KV := TO_INT(Open_CB2_22KV);
        Prev_Open_CB1_66KV := TO_INT(Open_CB1_66KV);
        Prev_Open_CB_TRSF1 := TO_INT(Open_CB_TRSF1);
        Prev_Open_CB2_66KV := TO_INT(Open_CB2_66KV);

        // Transition back to State 0
        FSM_State := 0;
    END_IF;

END_FUNCTION_BLOCK
END_ST