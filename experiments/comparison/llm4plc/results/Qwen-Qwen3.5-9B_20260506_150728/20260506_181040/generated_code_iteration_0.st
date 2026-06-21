START_ST
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
    MCB_CONTROL : BOOL;
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
    CurrentState : INT := 0;
END_VAR

VAR_TEMP
    NextState : INT;
    TempPP0, TempPP1, TempPP2, TempPP3, TempPP4, TempPP5, TempPP7, TempPPL3, TempPPL4, TempPPL5, TempPPL7 : BOOL;
    TempMCB, TempMCBR : BOOL;
END_VAR

BEGIN
    (* STATE MACHINE LOGIC *)
    (* The system iterates through states based on CurrentState *)
    
    CASE CurrentState OF
        0: (* STATE 0: INITIALIZATION *)
            (* Action: Set STABLE to 1 to indicate system is ready to start the sequence *)
            STABLE := TRUE;
            (* Note: In a real loop, the main program would call this FB. 
               Inside, we assume the first call sets STABLE to 1 to allow the first transition. *)
            CurrentState := 1;
            
        1: (* STATE 1: PP0 -> PP1 TRANSITION *)
            (* Condition: If PP0 is active, and both NOT MCB_CONTROL and NOT PP1 are true *)
            IF PP0 = TRUE AND MCB_CONTROL = FALSE AND PP1 = FALSE THEN
                TempPP0 := FALSE;
                TempPP1 := TRUE;
                STABLE := FALSE;
                CurrentState := 2;
            ELSE
                TempPP0 := PP0;
                TempPP1 := PP1;
                STABLE := STABLE;
                CurrentState := 1; (* Stay in state 1 *)
            END_IF;
            
        2: (* STATE 2: PP1 -> PP2 TRANSITION *)
            (* Condition: If PP1 is active and S_AL1_P_B1 is true, and NOT PP2 is true *)
            IF PP1 = TRUE AND S_AL1_P_B1 = TRUE AND PP2 = FALSE THEN
                TempPP1 := FALSE;
                TempPP2 := TRUE;
                STABLE := FALSE;
                CurrentState := 3;
            ELSE
                TempPP1 := PP1;
                TempPP2 := PP2;
                STABLE := STABLE;
                CurrentState := 2; (* Stay in state 2 *)
            END_IF;
            
        3: (* STATE 3: PP2 -> PP3 TRANSITION (Normal Path) *)
            (* Condition: If PP2 is active, S_AL1_P_B2 is true, NOT MCB_CONTROL is true, and NOT PP3 is true *)
            IF PP2 = TRUE AND S_AL1_P_B2 = TRUE AND MCB_CONTROL = FALSE AND PP3 = FALSE THEN
                TempPP2 := FALSE;
                TempPP3 := TRUE;
                STABLE := FALSE;
                CurrentState := 4;
            ELSE
                TempPP2 := PP2;
                TempPP3 := PP3;
                STABLE := STABLE;
                CurrentState := 3; (* Stay in state 3 *)
            END_IF;
            
        4: (* STATE 4: PP3 -> PP4 TRANSITION *)
            (* Condition: If PP3 is active, S_AL1_MCB is true, and both NOT PP4 and NOT PP1 are true *)
            IF PP3 = TRUE AND S_AL1_MCB = TRUE AND PP4 = FALSE AND PP1 = FALSE THEN
                TempPP3 := FALSE;
                TempPP4 := TRUE;
                TempPP1 := TRUE;
                STABLE := FALSE;
                CurrentState := 5;
            ELSE
                TempPP3 := PP3;
                TempPP4 := PP4;
                TempPP1 := PP1;
                STABLE := STABLE;
                CurrentState := 4; (* Stay in state 4 *)
            END_IF;
            
        5: (* STATE 5: PP4 -> PP5 TRANSITION *)
            (* Condition: If PP4 and MCB are true, and MCB_BUSY is true, and NOT PP5 is true *)
            IF PP4 = TRUE AND MCB = TRUE AND MCB_BUSY = TRUE AND PP5 = FALSE THEN
                TempPP4 := FALSE;
                TempMCB := FALSE;
                TempPP5 := TRUE;
                STABLE := FALSE;
                CurrentState := 6;
            ELSE
                TempPP4 := PP4;
                TempMCB := MCB;
                TempPP5 := PP5;
                STABLE := STABLE;
                CurrentState := 5; (* Stay in state 5 *)
            END_IF;
            
        6: (* STATE 6: PP5 -> PP7 TRANSITION *)
            (* Condition: If PP5 is active, S_AL1_MCB2 is true, NOT PP7 is true, and NOT MCB is true *)
            IF PP5 = TRUE AND S_AL1_MCB2 = TRUE AND PP7 = FALSE AND MCB = FALSE THEN
                TempPP5 := FALSE;
                TempPP7 := TRUE;
                TempMCB := TRUE;
                STABLE := FALSE;
                CurrentState := 7;
            ELSE
                TempPP5 := PP5;
                TempPP7 := PP7;
                TempMCB := MCB;
                STABLE := STABLE;
                CurrentState := 6; (* Stay in state 6 *)
            END_IF;
            
        7: (* STATE 7: PP7 -> END TRANSITION *)
            (* Condition: If PP7 is active and S_AL1_P_B3 is true *)
            IF PP7 = TRUE AND S_AL1_P_B3 = TRUE THEN
                TempPP7 := FALSE;
                STABLE := FALSE;
                CurrentState := 0; (* Reset to start for next cycle or end *)
            ELSE
                TempPP7 := PP7;
                STABLE := STABLE;
                CurrentState := 7; (* Stay in state 7 *)
            END_IF;
            
        8: (* STATE 8: PP2 -> PPL3 TRANSITION (Alternative Path) *)
            (* Condition: If PP2 is active, S_AL1_P_B2 is true, MCB_CONTROL is true, NOT PPL3 is true, and NOT PP1 is true *)
            IF PP2 = TRUE AND S_AL1_P_B2 = TRUE AND MCB_CONTROL = TRUE AND PPL3 = FALSE AND PP1 = FALSE THEN
                TempPP2 := FALSE;
                TempPPL3 := TRUE;
                TempPP1 := TRUE;
                STABLE := FALSE;
                CurrentState := 9;
            ELSE
                TempPP2 := PP2;
                TempPPL3 := PPL3;
                TempPP1 := PP1;
                STABLE := STABLE;
                CurrentState := 8; (* Stay in state 8 *)
            END_IF;
            
        9: (* STATE 9: PPL3 -> PPL4 TRANSITION *)
            (* Condition: If PPL3 is active, and S_AL1_MCBR is true, and NOT PPL4 is true *)
            IF PPL3 = TRUE AND S_AL1_MCBR = TRUE AND PPL4 = FALSE THEN
                TempPPL3 := FALSE;
                TempPPL4 := TRUE;
                STABLE := FALSE;
                CurrentState := 10;
            ELSE
                TempPPL3 := PPL3;
                TempPPL4 := PPL4;
                STABLE := STABLE;
                CurrentState := 9; (* Stay in state 9 *)
            END_IF;
            
        10: (* STATE 10: PPL4 -> PPL5 TRANSITION *)
            (* Condition: If PPL4 and MCBR are true, and MCBR_BUSY is true, and NOT PPL5 is true *)
            IF PPL4 = TRUE AND MCBR = TRUE AND MCBR_BUSY = TRUE AND PPL5 = FALSE THEN
                TempPPL4 := FALSE;
                TempMCBR := FALSE;
                TempPPL5 := TRUE;
                STABLE := FALSE;
                CurrentState := 11;
            ELSE
                TempPPL4 := PPL4;
                TempMCBR := MCBR;
                TempPPL5 := PPL5;
                STABLE := STABLE;
                CurrentState := 10; (* Stay in state 10 *)
            END_IF;
            
        11: (* STATE 11: PPL5 -> PPL7 TRANSITION *)
            (* Condition: If PPL5 is active, S_AL1_MCBR2 is true, NOT PPL7 is true, and NOT MCBR is true *)
            IF PPL5 = TRUE AND S_AL1_MCBR2 = TRUE AND PPL7 = FALSE AND MCBR = FALSE THEN
                TempPPL5 := FALSE;
                TempPPL7 := TRUE;
                TempMCBR := TRUE;
                STABLE := FALSE;
                CurrentState := 12;
            ELSE
                TempPPL5 := PPL5;
                TempPPL7 := PPL7;
                TempMCBR := MCBR;
                STABLE := STABLE;
                CurrentState := 11; (* Stay in state 11 *)
            END_IF;
            
        12: (* STATE 12: PPL7 -> END TRANSITION *)
            (* Condition: If PPL7 is active, and S_AL1_P_B3 is true *)
            IF PPL7 = TRUE AND S_AL1_P_B3 = TRUE THEN
                TempPPL7 := FALSE;
                STABLE := FALSE;
                CurrentState := 0; (* Reset to start for next cycle or end *)
            ELSE
                TempPPL7 := PPL7;
                STABLE := STABLE;
                CurrentState := 12; (* Stay in state 12 *)
            END_IF;
            
    END_CASE;
    
    (* Update State Variables based on transitions *)
    PP0 := TempPP0;
    PP1 := TempPP1;
    PP2 := TempPP2;
    PP3 := TempPP3;
    PP4 := TempPP4;
    MCB := TempMCB;
    PP5 := TempPP5;
    PP7 := TempPP7;
    PPL3 := TempPPL3;
    PPL4 := TempPPL4;
    MCBR := TempMCBR;
    PPL5 := TempPPL5;
    PPL7 := TempPPL7;
    
    (* OUTPUT LOGIC *)
    (* Calculated based on the final state of the cycle *)
    
    (* E_AL1_B1 := 1 IF (PP0 OR PP1) *)
    (* E_AL1_B1 := 0 IF (PP2 OR PP3 OR PPL3) *)
    (* Priority: If PP2/PP3/PPL3 is true, force 0. Else if PP0/PP1 is true, force 1. *)
    IF (PP2 = TRUE) OR (PP3 = TRUE) OR (PPL3 = TRUE) THEN
        E_AL1_B1 := FALSE;
    ELSE
        IF (PP0 = TRUE) OR (PP1 = TRUE) THEN
            E_AL1_B1 := TRUE;
        ELSE
            E_AL1_B1 := FALSE;
        END_IF;
    END_IF;
    
    (* MCB_CONTROL := 1 IF (PP3) *)
    (* MCB_CONTROL := 0 IF (PP0) *)
    (* Conflict Resolution: If PP3 is true, set to 1. If PP0 is true, set to 0. *)
    IF PP3 = TRUE THEN
        MCB_CONTROL := TRUE;
    ELSE
        IF PP0 = TRUE THEN
            MCB_CONTROL := FALSE;
        ELSE
            (* Default state if neither PP0 nor PP3 is active, based