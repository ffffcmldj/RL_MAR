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
END_VAR

VAR
    MCB_CONTROL : BOOL;
END_VAR

    STABLE := 0;
    
    WHILE STABLE = 0 DO
        STABLE := 1;
        
        // PP0 to PP1 transition
        IF PP0 = 1 AND MCB_CONTROL = 0 AND PP1 = 0 THEN
            PP0 := 0;
            PP1 := 1;
            STABLE := 0;
        END_IF;
        
        // PP1 to PP2 transition
        IF PP1 = 1 AND S_AL1_P_B1 = 1 AND PP2 = 0 THEN
            PP1 := 0;
            PP2 := 1;
            STABLE := 0;
        END_IF;
        
        // PP2 to PP3 transition
        IF PP2 = 1 AND S_AL1_P_B2 = 1 AND MCB_CONTROL = 0 AND PP3 = 0 THEN
            PP2 := 0;
            PP3 := 1;
            STABLE := 0;
        END_IF;
        
        // PP3 to PP4 transition
        IF PP3 = 1 AND S_AL1_MCB = 1 AND PP4 = 0 AND PP1 = 0 THEN
            PP3 := 0;
            PP4 := 1;
            PP1 := 1;
            STABLE := 0;
        END_IF;
        
        // PP4 to PP5 transition
        IF PP4 = 1 AND MCB = 1 AND MCB_BUSY = 1 AND PP5 = 0 THEN
            PP4 := 0;
            MCB := 0;
            PP5 := 1;
            STABLE := 0;
        END_IF;
        
        // PP5 to PP7 transition
        IF PP5 = 1 AND S_AL1_MCB2 = 1 AND PP7 = 0 AND MCB = 0 THEN
            PP5 := 0;
            PP7 := 1;
            MCB := 1;
            STABLE := 0;
        END_IF;
        
        // PP7 to End transition
        IF PP7 = 1 AND S_AL1_P_B3 = 1 THEN
            PP7 := 0;
            STABLE := 0;
        END_IF;
        
        // PP2 to PPL3 transition
        IF PP2 = 1 AND S_AL1_P_B2 = 1 AND MCB_CONTROL = 1 AND PPL3 = 0 AND PP1 = 0 THEN
            PP2 := 0;
            PPL3 := 1;
            PP1 := 1;
            STABLE := 0;
        END_IF;
        
        // PPL3 to PPL4 transition
        IF PPL3 = 1 AND S_AL1_MCBR = 1 AND PPL4 = 0 THEN
            PPL3 := 0;
            PPL4 := 1;
            STABLE := 0;
        END_IF;
        
        // PPL4 to PPL5 transition
        IF PPL4 = 1 AND MCBR = 1 AND MCBR_BUSY = 1 AND PPL5 = 0 THEN
            PPL4 := 0;
            MCBR := 0;
            PPL5 := 1;
            STABLE := 0;
        END_IF;
        
        // PPL5 to PPL7 transition
        IF PPL5 = 1 AND S_AL1_MCBR2 = 1 AND PPL7 = 0 AND MCBR = 0 THEN
            PPL5 := 0;
            PPL7 := 1;
            MCBR := 1;
            STABLE := 0;
        END_IF;
        
        // PPL7 to End transition
        IF PPL7 = 1 AND S_AL1_P_B3 = 1 THEN
            PPL7 := 0;
            STABLE := 0;
        END_IF;
    END_WHILE;
    
    // Output control logic
    // E_AL1_B1 control
    IF PP0 = 1 OR PP1 = 1 THEN
        E_AL1_B1 := 1;
    ELSIF PP2 = 1 OR PP3 = 1 OR PPL3 = 1 THEN
        E_AL1_B1 := 0;
    END_IF;
    
    // MCB_CONTROL control
    IF PP3 = 1 THEN
        MCB_CONTROL := 1;
    ELSIF PP0 = 1 OR PP3 = 1 THEN
        MCB_CONTROL := 0;
    END_IF;
    
    // PAS_AL1_PLUS and PAS_AL1_TURN control
    IF PPL3 = 1 OR PPL4 = 1 THEN
        PAS_AL1_PLUS := 1;
        PAS_AL1_TURN := 1;
    ELSIF PP0 = 1 OR PP3 = 1 OR PP4 = 1 THEN
        PAS_AL1_PLUS := 0;
        PAS_AL1_TURN := 0;
    END_IF;
    
    // PUWS_AL1_B1_PLUS control
    IF PPAL1 = 1 OR PP2 = 1 THEN
        PUWS_AL1_B1_PLUS := 1;
    END_IF;
    
    // PUWS_AL1_B1_RIGHT control
    IF PPAL1 = 1 OR PP2 = 1 THEN
        PUWS_AL1_B1_RIGHT := 0;
    END_IF;
    
END_FUNCTION_BLOCK