ructured-text
FUNCTION_BLOCK FB_AdvancedCircuitBreakerControl
VAR_INPUT
    S_AL1_P_B1 : BOOL;
    S_AL1_P_B2 : BOOL;
    S_AL1_MCB : BOOL;
    MCB_BUSY : BOOL;
    MCB_ERROR : BOOL;
    S_AL1_MCBR : BOOL;
    MCBR_BUSY : BOOL;
    MCBR_ERROR : BOOL;
    S_AL1_P_B3 : BOOL;
    S_AL1_MCB2 : BOOL;
    S_AL1_MCBR2 : BOOL;
END_VAR_INPUT

VAR_OUTPUT
    E_AL1_B1 : BOOL;
    PUWS_AL1_B1_PLUS : BOOL;
    PUWS_AL1_B1_RIGHT : BOOL;
    PAS_AL1_PLUS : BOOL;
    PAS_AL1_TURN : BOOL;
END_VAR_OUTPUT

VAR
    PPAL1 : BOOL := 1;
    PP0 : BOOL := 1;
    PP1 : BOOL := 0;
    PP2 : BOOL := 0;
    PP3 : BOOL := 0;
    PP4 : BOOL := 0;
    MCB : BOOL := 1;
    PP5 : BOOL := 0;
    PP7 : BOOL := 0;
    PPL3 : BOOL := 0;
    PPL4 : BOOL := 0;
    MCBR : BOOL := 1;
    PPL5 : BOOL := 0;
    PPL7 : BOOL := 0;
    STABLE : BOOL := 0;
    MCB_CONTROL : BOOL;
    state : INT; // THE STATE VARIABLE
    prevState : INT; // THE PREVIOUS STATE VARIABLE
END_VAR

// Initialization
STABLE := 0;
WHILE STABLE = 0 DO
    STABLE := 1;

// State machine operations
    // State 0 to State 1
    IF PP0 AND NOT MCB_CONTROL AND NOT PP1 THEN
        PP0 := 0;
        PP1 := 1;
        STABLE := 0;
    END_IF;

    // State 1 to State 2
    IF PP1 AND S_AL1_P_B1 AND NOT PP2 THEN
        PP1 := 0;
        PP2 := 1;
        STABLE := 0;
    END_IF;

    // State 2 to State 3
    IF PP2 AND S_AL1_P_B2 AND NOT MCB_CONTROL AND NOT PP3 THEN
        PP2 := 0;
        PP3 := 1;
        STABLE := 0;
    END_IF;

    // State 3 to State 4
    IF PP3 AND S_AL1_MCB AND NOT PP4 AND NOT PP1 THEN
        PP3 := 0;
        PP4 := 1;
        PP1 := 1;
        STABLE := 0;
    END_IF;

    // State 4 to State 5
    IF PP4 AND MCB AND MCB_BUSY AND NOT PP5 THEN
        PP4 := 0;
        MCB := 0;
        PP5 := 1;
        STABLE := 0;
    END_IF;

    // State 5 to State 7
    IF PP5 AND S_AL1_MCB2 AND NOT PP7 AND NOT MCB THEN
        PP5 := 0;
        PP7 := 1;
        MCB := 1;
        STABLE := 0;
    END_IF;

    // State 7 to End State
    IF PP7 AND S_AL1_P_B3 THEN
        PP7 := 0;
        STABLE := 0;
    END_IF;

    // State 2 to State 8
    IF PP2 AND S_AL1_P_B2 AND MCB_CONTROL AND NOT PPL3 AND NOT PP1 THEN
        PP2 := 0;
        PPL3 := 1;
        PP1 := 1;
        STABLE := 0;
    END_IF;

    // State 8 to State 9
    IF PPL3 AND S_AL1_MCBR AND NOT PPL4 THEN
        PPL3 := 0;
        PPL4 := 1;
        STABLE := 0;
    END_IF;

    // State 9 to State 10
    IF PPL4 AND MCBR AND MCBR_BUSY AND NOT PPL5 THEN
        PPL4 := 0;
        MCBR := 0;
        PPL5 := 1;
        STABLE := 0;
    END_IF;

    // State 10 to State 11
    IF PPL5 AND S_AL1_MCBR2 AND NOT PPL7 AND NOT MCBR THEN
        PPL5 := 0;
        PPL7 := 1;
        MCBR := 1;
        STABLE := 0;
    END_IF;

    // State 11 to End State
    IF PPL7 AND S_AL1_P_B3 THEN
        PPL7 := 0;
        STABLE := 0;
    END_IF;
END_WHILE;

// Output Control
E_AL1_B1 := (PP0 OR PP1);
MCB_CONTROL := PP3;
PAS_AL1_PLUS := (PPL3 OR PPL4);
PUWS_AL1_B1_PLUS := (PPAL1 OR PP2);
E_AL1_B1 := NOT (PP2 OR PP3 OR PPL3);
MCB_CONTROL := NOT (PP0 OR PP3);
PAS_AL1_PLUS := NOT (PP0 OR PP3 OR PP4);
PUWS_AL1_B1_RIGHT := NOT (PPAL1 OR PP2);

END_FUNCTION_BLOCK