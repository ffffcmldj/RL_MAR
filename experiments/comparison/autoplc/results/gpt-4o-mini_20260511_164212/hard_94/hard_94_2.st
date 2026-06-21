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

    // Initialization
    STABLE := FALSE;

    WHILE NOT STABLE DO
        STABLE := TRUE; // Assume stable until proven otherwise

        // State transitions
        IF PP0 AND NOT MCB_CONTROL AND NOT PP1 THEN
            PP0 := FALSE;
            PP1 := TRUE;
            STABLE := FALSE;
        ELSIF PP1 AND S_AL1_P_B1 AND NOT PP2 THEN
            PP1 := FALSE;
            PP2 := TRUE;
            STABLE := FALSE;
        ELSIF PP2 AND S_AL1_P_B2 AND NOT MCB_CONTROL AND NOT PP3 THEN
            PP2 := FALSE;
            PP3 := TRUE;
            STABLE := FALSE;
        ELSIF PP3 AND S_AL1_MCB AND NOT PP4 AND NOT PP1 THEN
            PP3 := FALSE;
            PP4 := TRUE;
            PP1 := TRUE;
            STABLE := FALSE;
        ELSIF PP4 AND MCB AND MCB_BUSY AND NOT PP5 THEN
            PP4 := FALSE;
            MCB := FALSE;
            PP5 := TRUE;
            STABLE := FALSE;
        ELSIF PP5 AND S_AL1_MCB2 AND NOT PP7 AND NOT MCB THEN
            PP5 := FALSE;
            PP7 := TRUE;
            MCB := TRUE;
            STABLE := FALSE;
        ELSIF PP7 AND S_AL1_P_B3 THEN
            PP7 := FALSE;
            STABLE := FALSE; // End state reached, but we keep looping until stable
        ELSIF PP2 AND S_AL1_P_B2 AND MCB_CONTROL AND NOT PPL3 AND NOT PP1 THEN
            PP2 := FALSE;
            PPL3 := TRUE;
            PP1 := TRUE;
            STABLE := FALSE;
        ELSIF PPL3 AND S_AL1_MCBR AND NOT PPL4 THEN
            PPL3 := FALSE;
            PPL4 := TRUE;
            STABLE := FALSE;
        ELSIF PPL4 AND MCBR AND MCBR_BUSY AND NOT PPL5 THEN
            PPL4 := FALSE;
            MCBR := FALSE;
            PPL5 := TRUE;
            STABLE := FALSE;
        ELSIF PPL5 AND S_AL1_MCBR2 AND NOT PPL7 AND NOT MCBR THEN
            PPL5 := FALSE;
            PPL7 := TRUE;
            MCBR := TRUE;
            STABLE := FALSE;
        ELSIF PPL7 AND S_AL1_P_B3 THEN
            PPL7 := FALSE;
            STABLE := FALSE; // End state reached, but we keep looping until stable
        END_IF;

        // Output Control Logic
        E_AL1_B1 := (PP0 OR PP1);
        MCB_CONTROL := PP3;
        PAS_AL1_PLUS := (PPL3 OR PPL4);
        PAS_AL1_TURN := (PPL3 OR PPL4);
        PUWS_AL1_B1_PLUS := (PPAL1 OR PP2);
        
        IF (PP2 OR PP3 OR PPL3) THEN
            E_AL1_B1 := FALSE;
        END_IF;

        IF (PP0 OR PP3) THEN
            MCB_CONTROL := FALSE;
        END_IF;

        IF (PP0 OR PP3 OR PP4) THEN
            PAS_AL1_PLUS := FALSE;
            PAS_AL1_TURN := FALSE;
        END_IF;

        IF (PPAL1 OR PP2) THEN
            PUWS_AL1_B1_RIGHT := FALSE;
        END_IF;
    END_WHILE;
END_FUNCTION_BLOCK