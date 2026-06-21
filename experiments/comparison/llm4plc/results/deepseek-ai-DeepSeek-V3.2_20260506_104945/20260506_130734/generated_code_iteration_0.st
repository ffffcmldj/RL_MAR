START_ST

FUNCTION_BLOCK FB_BreakerControlSystem
VAR_INPUT
    B10_1_Trip : BOOL;
    B10_1_Close : BOOL;
    B10_2_Trip : BOOL;
    B10_2_Close : BOOL;
    B10_12_Trip : BOOL;
    B10_12_Close : BOOL;
    B54_Trip : BOOL;
    B54_Close : BOOL;
    B55_Trip : BOOL;
    B55_Close : BOOL;
    B56_Trip : BOOL;
    B56_Close : BOOL;
    B57_Trip : BOOL;
    B57_Close : BOOL;
END_VAR
VAR_OUTPUT
    Point_1a : INT;
    Point_2a : INT;
    Point_3a : INT;
    Point_4a : INT;
    B10_1_Opened : BOOL;
    B10_1_Closed : BOOL;
    B10_2_Opened : BOOL;
    B10_2_Closed : BOOL;
    B10_12_Opened : BOOL;
    B10_12_Closed : BOOL;
    B54_Opened : BOOL;
    B54_Closed : BOOL;
    B55_Opened : BOOL;
    B55_Closed : BOOL;
    B56_Opened : BOOL;
    B56_Closed : BOOL;
    B57_Opened : BOOL;
    B57_Closed : BOOL;
END_VAR
VAR
    SEL86_OUT : INT;
    MOVE89_OUT : INT;
    SEL66_OUT : INT;
    MOVE69_OUT : INT;
    SEL96_OUT : INT;
    MOVE99_OUT : INT;
    SEL106_OUT : INT;
    MOVE109_OUT : INT;
    currentState : INT; (* 0: INITIALIZATION, 1: OPERATIONAL *)
END_VAR

(* State transition and main logic *)
CASE currentState OF
    0: (* INITIALIZATION *)
        (* Initialize all breaker states to opened (TRUE) and closed (FALSE) *)
        B10_1_Opened := TRUE;
        B10_1_Closed := FALSE;
        B10_2_Opened := TRUE;
        B10_2_Closed := FALSE;
        B10_12_Opened := TRUE;
        B10_12_Closed := FALSE;
        B54_Opened := TRUE;
        B54_Closed := FALSE;
        B55_Opened := TRUE;
        B55_Closed := FALSE;
        B56_Opened := TRUE;
        B56_Closed := FALSE;
        B57_Opened := TRUE;
        B57_Closed := FALSE;
        
        (* Initialize all point outputs to 138 *)
        Point_1a := 138;
        Point_2a := 138;
        Point_3a := 138;
        Point_4a := 138;
        
        (* Initialize intermediate variables to 0 *)
        SEL86_OUT := 0;
        MOVE89_OUT := 0;
        SEL66_OUT := 0;
        MOVE69_OUT := 0;
        SEL96_OUT := 0;
        MOVE99_OUT := 0;
        SEL106_OUT := 0;
        MOVE109_OUT := 0;
        
        (* Transition to OPERATIONAL state *)
        currentState := 1;
        
    1: (* OPERATIONAL *)
        (* Update breaker B10_1 state *)
        IF B10_1_Close AND NOT B10_1_Trip THEN
            B10_1_Closed := TRUE;
            B10_1_Opened := FALSE;
        ELSIF B10_1_Trip AND NOT B10_1_Close THEN
            B10_1_Closed := FALSE;
            B10_1_Opened := TRUE;
        END_IF;
        
        (* Update breaker B10_2 state *)
        IF B10_2_Close AND NOT B10_2_Trip THEN
            B10_2_Closed := TRUE;
            B10_2_Opened := FALSE;
        ELSIF B10_2_Trip AND NOT B10_2_Close THEN
            B10_2_Closed := FALSE;
            B10_2_Opened := TRUE;
        END_IF;
        
        (* Update breaker B10_12 state *)
        IF B10_12_Close AND NOT B10_12_Trip THEN
            B10_12_Closed := TRUE;
            B10_12_Opened := FALSE;
        ELSIF B10_12_Trip AND NOT B10_12_Close THEN
            B10_12_Closed := FALSE;
            B10_12_Opened := TRUE;
        END_IF;
        
        (* Update breaker B54 state *)
        IF B54_Close AND NOT B54_Trip THEN
            B54_Closed := TRUE;
            B54_Opened := FALSE;
        ELSIF B54_Trip AND NOT B54_Close THEN
            B54_Closed := FALSE;
            B54_Opened := TRUE;
        END_IF;
        
        (* Update breaker B55 state *)
        IF B55_Close AND NOT B55_Trip THEN
            B55_Closed := TRUE;
            B55_Opened := FALSE;
        ELSIF B55_Trip AND NOT B55_Close THEN
            B55_Closed := FALSE;
            B55_Opened := TRUE;
        END_IF;
        
        (* Update breaker B56 state *)
        IF B56_Close AND NOT B56_Trip THEN
            B56_Closed := TRUE;
            B56_Opened := FALSE;
        ELSIF B56_Trip AND NOT B56_Close THEN
            B56_Closed := FALSE;
            B56_Opened := TRUE;
        END_IF;
        
        (* Update breaker B57 state *)
        IF B57_Close AND NOT B57_Trip THEN
            B57_Closed := TRUE;
            B57_Opened := FALSE;
        ELSIF B57_Trip AND NOT B57_Close THEN
            B57_Closed := FALSE;
            B57_Opened := TRUE;
        END_IF;
        
        (* Calculate Point_1a *)
        IF B54_Closed AND ((B10_12_Closed AND B10_1_Closed) OR B10_2_Closed) THEN
            Point_1a := 0;
        ELSE
            Point_1a := 138;
        END_IF;
        
        (* Calculate Point_2a *)
        IF B55_Closed AND ((B10_12_Closed AND B10_1_Closed) OR B10_2_Closed) THEN
            Point_2a := 0;
        ELSE
            Point_2a := 138;
        END_IF;
        
        (* Calculate Point_3a *)
        IF B56_Closed AND ((B10_12_Closed AND B10_2_Closed) OR B10_1_Closed) THEN
            Point_3a := 0;
        ELSE
            Point_3a := 138;
        END_IF;
        
        (* Calculate Point_4a *)
        IF B57_Closed AND ((B10_12_Closed AND B10_2_Closed) OR B10_1_Closed) THEN
            Point_4a := 0;
        ELSE
            Point_4a := 138;
        END_IF;
        
        (* Remain in OPERATIONAL state *)
        currentState := 1;
        
END_CASE;

END_FUNCTION_BLOCK

END_ST