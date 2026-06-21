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
    PPAL1 : BOOL := TRUE;
    PP0 : BOOL := TRUE;
    PP1 : BOOL := FALSE;
    PP2 : BOOL := FALSE;
    PP3 : BOOL := FALSE;
    PP4 : BOOL := FALSE;
    MCB : BOOL := TRUE;
    PP5 : BOOL := FALSE;
    PP7 : BOOL := FALSE;
    PPL3 : BOOL := FALSE;
    PPL4 : BOOL := FALSE;
    MCBR : BOOL := TRUE;
    PPL5 : BOOL := FALSE;
    PPL7 : BOOL := FALSE;
    STABLE : BOOL := FALSE;
    MCB_CONTROL : BOOL;
END_VAR

METHOD Main : BOOL
VAR_INST
END_VAR

STABLE := FALSE;

WHILE (STABLE = FALSE) DO
    STABLE := TRUE;
    
    // PP0 to PP1
    IF (PP0 = TRUE) AND (NOT MCB_CONTROL) AND (PP1 = FALSE) THEN
        PP0 := FALSE;
        PP1 := TRUE;
        STABLE := FALSE;
    END_IF;
    
    // PP1 to PP2
    IF (PP1 = TRUE) AND S_AL1_P_B1 AND (PP2 = FALSE) THEN
        PP1 := FALSE;
        PP2 := TRUE;
        STABLE := FALSE;
    END_IF;
    
    // PP2 to PP3
    IF (PP2 = TRUE) AND S_AL1_P_B2 AND (NOT MCB_CONTROL) AND (PP3 = FALSE) THEN
        PP2 := FALSE;
        PP3 := TRUE;
        STABLE := FALSE;
    END_IF;
    
    // PP3 to PP4
    IF (PP3 = TRUE) AND S_AL1_MCB AND (PP4 = FALSE) AND (PP1 = FALSE) THEN
        PP3 := FALSE;
        PP4 := TRUE;
        PP1 := TRUE;
        STABLE := FALSE;
    END_IF;
    
    // PP4 to PP5
    IF (PP4 = TRUE) AND (MCB = TRUE) AND MCB_BUSY AND (PP5 = FALSE) THEN
        PP4 := FALSE;
        MCB := FALSE;
        PP5 := TRUE;
        STABLE := FALSE;
    END_IF;
    
    // PP5 to PP7
    IF (PP5 = TRUE) AND S_AL1_MCB2 AND (PP7 = FALSE) AND (MCB = FALSE) THEN
        PP5 := FALSE;
        PP7 := TRUE;
        MCB := TRUE;
        STABLE := FALSE;
    END_IF;
    
    // PP7 to End
    IF (PP7 = TRUE) AND S_AL1_P_B3 THEN
        PP7 := FALSE;
        STABLE := FALSE;
    END_IF;
    
    // PP2 to PPL3
    IF (PP2 = TRUE) AND S_AL1_P_B2 AND MCB_CONTROL AND (PPL3 = FALSE) AND (PP1 = FALSE) THEN
        PP2 := FALSE;
        PPL3 := TRUE;
        PP1 := TRUE;
        STABLE := FALSE;
    END_IF;
    
    // PPL3 to PPL4
    IF (PPL3 = TRUE) AND S_AL1_MCBR AND (PPL4 = FALSE) THEN
        PPL3 := FALSE;
        PPL4 := TRUE;
        STABLE := FALSE;
    END_IF;
    
    // PPL4 to PPL5
    IF (PPL4 = TRUE) AND (MCBR = TRUE) AND MCBR_BUSY AND (PPL5 = FALSE) THEN
        PPL4 := FALSE;
        MCBR := FALSE;
        PPL5 := TRUE;
        STABLE := FALSE;
    END_IF;
    
    // PPL5 to PPL7
    IF (PPL5 = TRUE) AND S_AL1_MCBR2 AND (PPL7 = FALSE) AND (MCBR = FALSE) THEN
        PPL5 := FALSE;
        PPL7 := TRUE;
        MCBR := TRUE;
        STABLE := FALSE;
    END_IF;
    
    // PPL7 to End
    IF (PPL7 = TRUE) AND S_AL1_P_B3 THEN
        PPL7 := FALSE;
        STABLE := FALSE;
    END_IF;
END_WHILE;

// Output Control
// Set outputs based on active states
IF (PP0 = TRUE) OR (PP1 = TRUE) THEN
    E_AL1_B1 := TRUE;
ELSE
    E_AL1_B1 := FALSE;
END_IF;

IF (PP3 = TRUE) THEN
    MCB_CONTROL := TRUE;
ELSE
    MCB_CONTROL := FALSE;
END_IF;

IF (PPL3 = TRUE) OR (PPL4 = TRUE) THEN
    PAS_AL1_PLUS := TRUE;
    PAS_AL1_TURN := TRUE;
ELSE
    PAS_AL1_PLUS := FALSE;
    PAS_AL1_TURN := FALSE;
END_IF;

IF (PPAL1 = TRUE) OR (PP2 = TRUE) THEN
    PUWS_AL1_B1_PLUS := TRUE;
ELSE
    PUWS_AL1_B1_PLUS := FALSE;
END_IF;

IF (PP2 = TRUE) OR (PP3 = TRUE) OR (PPL3 = TRUE) THEN
    E_AL1_B1 := FALSE;
END_IF;

IF (PP0 = TRUE) OR (PP3 = TRUE) THEN
    MCB_CONTROL := FALSE;
END_IF;

IF (PP0 = TRUE) OR (PP3 = TRUE) OR (PP4 = TRUE) THEN
    PAS_AL1_PLUS := FALSE;
    PAS_AL1_TURN := FALSE;
END_IF;

IF (PPAL1 = TRUE) OR (PP2 = TRUE) THEN
    PUWS_AL1_B1_RIGHT := FALSE;
END_IF;

Main := TRUE;
END_METHOD

END_FUNCTION_BLOCK