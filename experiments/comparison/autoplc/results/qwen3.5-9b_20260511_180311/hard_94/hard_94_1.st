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

IF STABLE = FALSE THEN
    STABLE := TRUE;

    IF PP0 = TRUE THEN
        IF MCB_CONTROL = FALSE AND PP1 = FALSE THEN
            PP0 := FALSE;
            PP1 := TRUE;
            STABLE := FALSE;
        END_IF;
    END_IF;

    IF PP1 = TRUE THEN
        IF S_AL1_P_B1 = TRUE AND PP2 = FALSE THEN
            PP1 := FALSE;
            PP2 := TRUE;
            STABLE := FALSE;
        END_IF;
    END_IF;

    IF PP2 = TRUE THEN
        IF S_AL1_P_B2 = TRUE AND MCB_CONTROL = FALSE AND PP3 = FALSE THEN
            PP2 := FALSE;
            PP3 := TRUE;
            STABLE := FALSE;
        END_IF;
        IF S_AL1_P_B2 = TRUE AND MCB_CONTROL = TRUE AND PPL3 = FALSE AND PP1 = FALSE THEN
            PP2 := FALSE;
            PPL3 := TRUE;
            PP1 := TRUE;
            STABLE := FALSE;
        END_IF;
    END_IF;

    IF PP3 = TRUE THEN
        IF S_AL1_MCB = TRUE AND PP4 = FALSE AND PP1 = FALSE THEN
            PP3 := FALSE;
            PP4 := TRUE;
            PP1 := TRUE;
            STABLE := FALSE;
        END_IF;
    END_IF;

    IF PP4 = TRUE THEN
        IF MCB = TRUE AND MCB_BUSY = TRUE AND PP5 = FALSE THEN
            PP4 := FALSE;
            MCB := FALSE;
            PP5 := TRUE;
            STABLE := FALSE;
        END_IF;
    END_IF;

    IF PP5 = TRUE THEN
        IF S_AL1_MCB2 = TRUE AND PP7 = FALSE AND MCB = FALSE THEN
            PP5 := FALSE;
            PP7 := TRUE;
            MCB := TRUE;
            STABLE := FALSE;
        END_IF;
    END_IF;

    IF PP7 = TRUE THEN
        IF S_AL1_P_B3 = TRUE THEN
            PP7 := FALSE;
            STABLE := FALSE;
        END_IF;
    END_IF;

    IF PPL3 = TRUE THEN
        IF S_AL1_MCBR = TRUE AND PPL4 = FALSE THEN
            PPL3 := FALSE;
            PPL4 := TRUE;
            STABLE := FALSE;
        END_IF;
    END_IF;

    IF PPL4 = TRUE THEN
        IF MCBR = TRUE AND MCBR_BUSY = TRUE AND PPL5 = FALSE THEN
            PPL4 := FALSE;
            MCBR := FALSE;
            PPL5 := TRUE;
            STABLE := FALSE;
        END_IF;
    END_IF;

    IF PPL5 = TRUE THEN
        IF S_AL1_MCBR2 = TRUE AND PPL7 = FALSE AND MCBR = FALSE THEN
            PPL5 := FALSE;
            PPL7 := TRUE;
            MCBR := TRUE;
            STABLE := FALSE;
        END_IF;
    END_IF;

    IF PPL7 = TRUE THEN
        IF S_AL1_P_B3 = TRUE THEN
            PPL7 := FALSE;
            STABLE := FALSE;
        END_IF;
    END_IF;

    IF PP0 = TRUE OR PP1 = TRUE THEN
        E_AL1_B1 := TRUE;
    END_IF;

    IF PP3 = TRUE THEN
        MCB_CONTROL := TRUE;
    END_IF;

    IF PP0 = TRUE OR PP3 = TRUE THEN
        MCB_CONTROL := FALSE;
    END_IF;

    IF PPL3 = TRUE OR PPL4 = TRUE THEN
        PAS_AL1_PLUS := TRUE;
        PAS_AL1_TURN := TRUE;
    END_IF;

    IF PP0 = TRUE OR PP3 = TRUE OR PP4 = TRUE THEN
        PAS_AL1_PLUS := FALSE;
        PAS_AL1_TURN := FALSE;
    END_IF;

    IF PPAL1 = TRUE OR PP2 = TRUE THEN
        PUWS_AL1_B1_PLUS := TRUE;
        PUWS_AL1_B1_RIGHT := FALSE;
    END_IF;

    IF PP2 = TRUE OR PP3 = TRUE OR PPL3 = TRUE THEN
        E_AL1_B1 := FALSE;
    END_IF;

    IF PPAL1 = TRUE OR PP2 = TRUE THEN
        PUWS_AL1_B1_RIGHT := FALSE;
    END_IF;

END_IF
END_FUNCTION_BLOCK