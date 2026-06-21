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
    (* State Variables - Only one should be active at a time *)
    PPAL1 : BOOL := 1;
    PP0 : BOOL := 0;
    PP1 : BOOL := 0;
    PP2 : BOOL := 0;
    PP3 : BOOL := 0;
    PP4 : BOOL := 0;
    PP5 : BOOL := 0;
    PP7 : BOOL := 0;
    PPL3 : BOOL := 0;
    PPL4 : BOOL := 0;
    PPL5 : BOOL := 0;
    PPL7 : BOOL := 0;
    
    (* Internal Control and Status Flags *)
    MCB : BOOL := 1;
    MCBR : BOOL := 1;
    MCB_CONTROL : BOOL;
    STABLE : BOOL;
END_VAR

(* Main State Machine Logic *)
STABLE := 0;
WHILE (STABLE = 0) DO
    STABLE := 1;
    
    (* State PP0 to PP1 *)
    IF (PP0 = 1) AND (NOT MCB_CONTROL) AND (PP1 = 0) THEN
        PP0 := 0;
        PP1 := 1;
        STABLE := 0;
    END_IF;
    
    (* State PP1 to PP2 *)
    IF (PP1 = 1) AND S_AL1_P_B1 AND (PP2 = 0) THEN
        PP1 := 0;
        PP2 := 1;
        STABLE := 0;
    END_IF;
    
    (* State PP2 to PP3 (Main Path) *)
    IF (PP2 = 1) AND S_AL1_P_B2 AND (NOT MCB_CONTROL) AND (PP3 = 0) THEN
        PP2 := 0;
        PP3 := 1;
        STABLE := 0;
    END_IF;
    
    (* State PP2 to PPL3 (Alternative Path) *)
    IF (PP2 = 1) AND S_AL1_P_B2 AND MCB_CONTROL AND (PPL3 = 0) AND (PP1 = 0) THEN
        PP2 := 0;
        PPL3 := 1;
        PP1 := 1;
        STABLE := 0;
    END_IF;
    
    (* State PP3 to PP4 *)
    IF (PP3 = 1) AND S_AL1_MCB AND (PP4 = 0) AND (PP1 = 0) THEN
        PP3 := 0;
        PP4 := 1;
        PP1 := 1;
        STABLE := 0;
    END_IF;
    
    (* State PP4 to PP5 *)
    IF (PP4 = 1) AND (MCB = 1) AND MCB_BUSY AND (PP5 = 0) THEN
        PP4 := 0;
        MCB := 0;
        PP5 := 1;
        STABLE := 0;
    END_IF;
    
    (* State PP5 to PP7 *)
    IF (PP5 = 1) AND S_AL1_MCB2 AND (PP7 = 0) AND (MCB = 0) THEN
        PP5 := 0;
        PP7 := 1;
        MCB := 1;
        STABLE := 0;
    END_IF;
    
    (* State PP7 to End *)
    IF (PP7 = 1) AND S_AL1_P_B3 THEN
        PP7 := 0;
        STABLE := 0;
    END_IF;
    
    (* State PPL3 to PPL4 *)
    IF (PPL3 = 1) AND S_AL1_MCBR AND (PPL4 = 0) THEN
        PPL3 := 0;
        PPL4 := 1;
        STABLE := 0;
    END_IF;
    
    (* State PPL4 to PPL5 *)
    IF (PPL4 = 1) AND (MCBR = 1) AND MCBR_BUSY AND (PPL5 = 0) THEN
        PPL4 := 0;
        MCBR := 0;
        PPL5 := 1;
        STABLE := 0;
    END_IF;
    
    (* State PPL5 to PPL7 *)
    IF (PPL5 = 1) AND S_AL1_MCBR2 AND (PPL7 = 0) AND (MCBR = 0) THEN
        PPL5 := 0;
        PPL7 := 1;
        MCBR := 1;
        STABLE := 0;
    END_IF;
    
    (* State PPL7 to End *)
    IF (PPL7 = 1) AND S_AL1_P_B3 THEN
        PPL7 := 0;
        STABLE := 0;
    END_IF;
END_WHILE;

(* Output Control Logic *)
(* Initialize all outputs to FALSE *)
E_AL1_B1 := 0;
PUWS_AL1_B1_PLUS := 0;
PUWS_AL1_B1_RIGHT := 0;
PAS_AL1_PLUS := 0;
PAS_AL1_TURN := 0;
MCB_CONTROL := 0;

(* Set outputs based on active states *)
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