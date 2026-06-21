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
END_VAR

VAR_OUTPUT
    E_AL1_B1 : BOOL;
    PUWS_AL1_B1_PLUS : BOOL;
    PUWS_AL1_B1_RIGHT : BOOL;
    PAS_AL1_PLUS : BOOL;
    PAS_AL1_TURN : BOOL;
END_VAR

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
END_VAR

STABLE := 0;
WHILE (STABLE = 0) DO
    STABLE := 1;

    IF (PP0 = 1) AND (NOT MCB_CONTROL) AND (NOT PP1) THEN
        PP0 := 0;
        PP1 := 1;
        STABLE := 0;
    END_IF;

    IF (PP1 = 1) AND S_AL1_P_B1 AND (NOT PP2) THEN
        PP1 := 0;
        PP2 := 1;
        STABLE := 0;
    END_IF;

    IF (PP2 = 1) AND S_AL1_P_B2 AND (NOT MCB_CONTROL) AND (NOT PP3) THEN
        PP2 := 0;
        PP3 := 1;
        STABLE := 0;
    END_IF;

    IF (PP2 = 1) AND S_AL1_P_B2 AND MCB_CONTROL AND (NOT PPL3) AND (NOT PP1) THEN
        PP2 := 0;
        PPL3 := 1;
        PP1 := 1;
        STABLE := 0;
    END_IF;

    IF (PP3 = 1) AND S_AL1_MCB AND (NOT PP4) AND (NOT PP1) THEN
        PP3 := 0;
        PP4 := 1;
        PP1 := 1;
        STABLE := 0;
    END_IF;

    IF (PP4 = 1) AND (MCB = 1) AND MCB_BUSY AND (NOT PP5) THEN
        PP4 := 0;
        MCB := 0;
        PP5 := 1;
        STABLE := 0;
    END_IF;

    IF (PP5 = 1) AND S_AL1_MCB2 AND (NOT PP7) AND (NOT MCB) THEN
        PP5 := 0;
        PP7 := 1;
        MCB := 1;
        STABLE := 0;
    END_IF;

    IF (PP7 = 1) AND S_AL1_P_B3 THEN
        PP7 := 0;
        STABLE := 0;
    END_IF;

    IF (PPL3 = 1) AND S_AL1_MCBR AND (NOT PPL4) THEN
        PPL3 := 0;
        PPL4 := 1;
        STABLE := 0;
    END_IF;

    IF (PPL4 = 1) AND (MCBR = 1) AND MCBR_BUSY AND (NOT PPL5) THEN
        PPL4 := 0;
        MCBR := 0;
        PPL5 := 1;
        STABLE := 0;
    END_IF;

    IF (PPL5 = 1) AND S_AL1_MCBR2 AND (NOT PPL7) AND (NOT MCBR) THEN
        PPL5 := 0;
        PPL7 := 1;
        MCBR := 1;
        STABLE := 0;
    END_IF;

    IF (PPL7 = 1) AND S_AL1_P_B3 THEN
        PPL7 := 0;
        STABLE := 0;
    END_IF;
END_WHILE;

IF (PP0 = 1) OR (PP1 = 1) THEN
    E_AL1_B1 := 1;
END_IF;

IF (PP3 = 1) THEN
    MCB_CONTROL := 1;
END_IF;

IF (PPL3 = 1) OR (PPL4 = 1) THEN
    PAS_AL1_PLUS := 1;
    PAS_AL1_TURN := 1;
END_IF;

IF (PPAL1 = 1) OR (PP2 = 1) THEN
    PUWS_AL1_B1_PLUS := 1;
END_IF;

IF (PP2 = 1) OR (PP3 = 1) OR (PPL3 = 1) THEN
    E_AL1_B1 := 0;
END_IF;

IF (PP0 = 1) OR (PP3 = 1) THEN
    MCB_CONTROL := 0;
END_IF;

IF (PP0 = 1) OR (PP3 = 1) OR (PP4 = 1) THEN
    PAS_AL1_PLUS := 0;
    PAS_AL1_TURN := 0;
END_IF;

IF (PPAL1 = 1) OR (PP2 = 1) THEN
    PUWS_AL1_B1_RIGHT := 0;
END_IF;

END_FUNCTION_BLOCK