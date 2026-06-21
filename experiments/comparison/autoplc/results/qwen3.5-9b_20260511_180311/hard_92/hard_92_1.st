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
END_VAR

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

IF B10_1_Trip = TRUE THEN
    B10_1_Opened := TRUE;
    B10_1_Closed := FALSE;
ELSIF B10_1_Close = TRUE THEN
    B10_1_Opened := FALSE;
    B10_1_Closed := TRUE;
END_IF;

IF B10_2_Trip = TRUE THEN
    B10_2_Opened := TRUE;
    B10_2_Closed := FALSE;
ELSIF B10_2_Close = TRUE THEN
    B10_2_Opened := FALSE;
    B10_2_Closed := TRUE;
END_IF;

IF B10_12_Trip = TRUE THEN
    B10_12_Opened := TRUE;
    B10_12_Closed := FALSE;
ELSIF B10_12_Close = TRUE THEN
    B10_12_Opened := FALSE;
    B10_12_Closed := TRUE;
END_IF;

IF B54_Trip = TRUE THEN
    B54_Opened := TRUE;
    B54_Closed := FALSE;
ELSIF B54_Close = TRUE THEN
    B54_Opened := FALSE;
    B54_Closed := TRUE;
END_IF;

IF B55_Trip = TRUE THEN
    B55_Opened := TRUE;
    B55_Closed := FALSE;
ELSIF B55_Close = TRUE THEN
    B55_Opened := FALSE;
    B55_Closed := TRUE;
END_IF;

IF B56_Trip = TRUE THEN
    B56_Opened := TRUE;
    B56_Closed := FALSE;
ELSIF B56_Close = TRUE THEN
    B56_Opened := FALSE;
    B56_Closed := TRUE;
END_IF;

IF B57_Trip = TRUE THEN
    B57_Opened := TRUE;
    B57_Closed := FALSE;
ELSIF B57_Close = TRUE THEN
    B57_Opened := FALSE;
    B57_Closed := TRUE;
END_IF;

IF (B54_Closed = TRUE) AND ((B10_12_Closed = TRUE) AND (B10_1_Closed = TRUE) OR B10_2_Closed = TRUE) THEN
    Point_1a := 0;
ELSE
    Point_1a := 138;
END_IF;

IF (B55_Closed = TRUE) AND ((B10_12_Closed = TRUE) AND (B10_1_Closed = TRUE) OR B10_2_Closed = TRUE) THEN
    Point_2a := 0;
ELSE
    Point_2a := 138;
END_IF;

IF (B56_Closed = TRUE) AND ((B10_12_Closed = TRUE) AND (B10_2_Closed = TRUE) OR B10_1_Closed = TRUE) THEN
    Point_3a := 0;
ELSE
    Point_3a := 138;
END_IF;

IF (B57_Closed = TRUE) AND ((B10_12_Closed = TRUE) AND (B10_2_Closed = TRUE) OR B10_1_Closed = TRUE) THEN
    Point_4a := 0;
ELSE
    Point_4a := 138;
END_IF;

END_FUNCTION_BLOCK