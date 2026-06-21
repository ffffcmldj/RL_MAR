plaintext
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
    state : INT := 0;
    prevState : INT := -1;
    SEL86_OUT : INT;
    MOVE89_OUT : INT;
    SEL66_OUT : INT;
    MOVE69_OUT : INT;
    SEL96_OUT : INT;
    MOVE99_OUT : INT;
    SEL106_OUT : INT;
    MOVE109_OUT : INT;
END_VAR

// State Machine Implementation
CASE state OF
    0: // STATE 0: Initialize
        B10_1_Opened := FALSE;
        B10_1_Closed := FALSE;
        B10_2_Opened := FALSE;
        B10_2_Closed := FALSE;
        B10_12_Opened := FALSE;
        B10_12_Closed := FALSE;
        B54_Opened := FALSE;
        B54_Closed := FALSE;
        B55_Opened := FALSE;
        B55_Closed := FALSE;
        B56_Opened := FALSE;
        B56_Closed := FALSE;
        B57_Opened := FALSE;
        B57_Closed := FALSE;
        Point_1a := 138;
        Point_2a := 138;
        Point_3a := 138;
        Point_4a := 138;
        state := 1;

    1: // STATE 1: Manage Breaker B10_1
        IF B10_1_Close THEN
            B10_1_Closed := TRUE;
            B10_1_Opened := FALSE;
        ELSIF B10_1_Trip THEN
            B10_1_Closed := FALSE;
            B10_1_Opened := TRUE;
        END_IF;
        state := 2;

    2: // STATE 2: Manage Breaker B10_2
        IF B10_2_Close THEN
            B10_2_Closed := TRUE;
            B10_2_Opened := FALSE;
        ELSIF B10_2_Trip THEN
            B10_2_Closed := FALSE;
            B10_2_Opened := TRUE;
        END_IF;
        state := 3;

    3: // STATE 3: Manage Breaker B10_12
        IF B10_12_Close THEN
            B10_12_Closed := TRUE;
            B10_12_Opened := FALSE;
        ELSIF B10_12_Trip THEN
            B10_12_Closed := FALSE;
            B10_12_Opened := TRUE;
        END_IF;
        state := 4;

    4: // STATE 4: Manage Breaker B54
        IF B54_Close THEN
            B54_Closed := TRUE;
            B54_Opened := FALSE;
        ELSIF B54_Trip THEN
            B54_Closed := FALSE;
            B54_Opened := TRUE;
        END_IF;
        state := 5;

    5: // STATE 5: Manage Breaker B55
        IF B55_Close THEN
            B55_Closed := TRUE;
            B55_Opened := FALSE;
        ELSIF B55_Trip THEN
            B55_Closed := FALSE;
            B55_Opened := TRUE;
        END_IF;
        state := 6;

    6: // STATE 6: Manage Breaker B56
        IF B56_Close THEN
            B56_Closed := TRUE;
            B56_Opened := FALSE;
        ELSIF B56_Trip THEN
            B56_Closed := FALSE;
            B56_Opened := TRUE;
        END_IF;
        state := 7;

    7: // STATE 7: Manage Breaker B57
        IF B57_Close THEN
            B57_Closed := TRUE;
            B57_Opened := FALSE;
        ELSIF B57_Trip THEN
            B57_Closed := FALSE;
            B57_Opened := TRUE;
        END_IF;
        state := 8;

    8: // STATE 8: Calculate Point_1a
        IF B54_Closed AND ((B10_12_Closed AND B10_1_Closed) OR B10_2_Closed) THEN
            Point_1a := 0;
        ELSE
            Point_1a := 138;
        END_IF;
        state := 9;

    9: // STATE 9: Calculate Point_2a
        IF B55_Closed AND ((B10_12_Closed AND B10_1_Closed) OR B10_2_Closed) THEN
            Point_2a := 0;
        ELSE
            Point_2a := 138;
        END_IF;
        state := 10;

    10: // STATE 10: Calculate Point_3a
        IF B56_Closed AND ((B10_12_Closed AND B10_2_Closed) OR B10_1_Closed) THEN
            Point_3a := 0;
        ELSE
            Point_3a := 138;
        END_IF;
        state := 11;

    11: // STATE 11: Calculate Point_4a
        IF B57_Closed AND ((B10_12_Closed AND B10_2_Closed) OR B10_1_Closed) THEN
            Point_4a := 0;
        ELSE
            Point_4a := 138;
        END_IF;
        state := 0;

    ELSE
        state := 0; // Default to initialization state
END_CASE;

END_FUNCTION_BLOCK
END_ST