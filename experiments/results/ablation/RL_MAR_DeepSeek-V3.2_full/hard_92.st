TYPE
    BreakerState : STRUCT
        Opened : BOOL;
        Closed : BOOL;
    END_STRUCT;

    BreakerControl : STRUCT
        Trip : BOOL;
        Close : BOOL;
    END_STRUCT;

    BreakerData : STRUCT
        Control : BreakerControl;
        State : BreakerState;
    END_STRUCT;

    PointData : STRUCT
        Value : INT;
    END_STRUCT;
END_TYPE;

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

(* Breaker State Management *)
IF B10_1_Close = TRUE THEN
    B10_1_Closed := TRUE;
    B10_1_Opened := FALSE;
ELSIF B10_1_Trip = TRUE THEN
    B10_1_Closed := FALSE;
    B10_1_Opened := TRUE;
END_IF;

IF B10_2_Close = TRUE THEN
    B10_2_Closed := TRUE;
    B10_2_Opened := FALSE;
ELSIF B10_2_Trip = TRUE THEN
    B10_2_Closed := FALSE;
    B10_2_Opened := TRUE;
END_IF;

IF B10_12_Close = TRUE THEN
    B10_12_Closed := TRUE;
    B10_12_Opened := FALSE;
ELSIF B10_12_Trip = TRUE THEN
    B10_12_Closed := FALSE;
    B10_12_Opened := TRUE;
END_IF;

IF B54_Close = TRUE THEN
    B54_Closed := TRUE;
    B54_Opened := FALSE;
ELSIF B54_Trip = TRUE THEN
    B54_Closed := FALSE;
    B54_Opened := TRUE;
END_IF;

IF B55_Close = TRUE THEN
    B55_Closed := TRUE;
    B55_Opened := FALSE;
ELSIF B55_Trip = TRUE THEN
    B55_Closed := FALSE;
    B55_Opened := TRUE;
END_IF;

IF B56_Close = TRUE THEN
    B56_Closed := TRUE;
    B56_Opened := FALSE;
ELSIF B56_Trip = TRUE THEN
    B56_Closed := FALSE;
    B56_Opened := TRUE;
END_IF;

IF B57_Close = TRUE THEN
    B57_Closed := TRUE;
    B57_Opened := FALSE;
ELSIF B57_Trip = TRUE THEN
    B57_Closed := FALSE;
    B57_Opened := TRUE;
END_IF;

(* Point Calculations *)
IF (B54_Closed = TRUE) AND (((B10_12_Closed = TRUE) AND (B10_1_Closed = TRUE)) OR (B10_2_Closed = TRUE)) THEN
    Point_1a := 0;
ELSE
    Point_1a := 138;
END_IF;

IF (B55_Closed = TRUE) AND (((B10_12_Closed = TRUE) AND (B10_1_Closed = TRUE)) OR (B10_2_Closed = TRUE)) THEN
    Point_2a := 0;
ELSE
    Point_2a := 138;
END_IF;

IF (B56_Closed = TRUE) AND (((B10_12_Closed = TRUE) AND (B10_2_Closed = TRUE)) OR (B10_1_Closed = TRUE)) THEN
    Point_3a := 0;
ELSE
    Point_3a := 138;
END_IF;

IF (B57_Closed = TRUE) AND (((B10_12_Closed = TRUE) AND (B10_2_Closed = TRUE)) OR (B10_1_Closed = TRUE)) THEN
    Point_4a := 0;
ELSE
    Point_4a := 138;
END_IF;

END_FUNCTION_BLOCK;