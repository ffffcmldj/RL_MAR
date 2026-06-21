TYPE
    ST_BreakerStatus :
    STRUCT
        Opened : BOOL;
        Closed : BOOL;
    END_STRUCT;

    ST_BreakerControl :
    STRUCT
        Trip : BOOL;
        Close : BOOL;
    END_STRUCT;

    ST_BreakerData :
    STRUCT
        Control : ST_BreakerControl;
        Status : ST_BreakerStatus;
    END_STRUCT;

    ST_PointData :
    STRUCT
        Point_1a : INT;
        Point_2a : INT;
        Point_3a : INT;
        Point_4a : INT;
    END_STRUCT;

    E_BreakerID :
    (
        B10_1,
        B10_2,
        B10_12,
        B54,
        B55,
        B56,
        B57
    );
END_TYPE

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
    // Internal structured data storage for breakers and points
    rBreakers : ARRAY[E_BreakerID] OF ST_BreakerData;
    rPoints : ST_PointData;
    // Intermediate condition variables
    bCondition_1A : BOOL;
    bCondition_2A : BOOL;
    // Internal variables as per original specification (initialized but not used in core logic)
    SEL86_OUT : INT;
    MOVE89_OUT : INT;
    SEL66_OUT : INT;
    MOVE69_OUT : INT;
    SEL96_OUT : INT;
    MOVE99_OUT : INT;
    SEL106_OUT : INT;
    MOVE109_OUT : INT;
END_VAR

// Main Execution Logic
// Step 1: Update all breaker states based on control signals
// Breaker B10_1
IF rBreakers[B10_1].Control.Close <> B10_1_Close THEN
    rBreakers[B10_1].Control.Close := B10_1_Close;
END_IF;
IF rBreakers[B10_1].Control.Trip <> B10_1_Trip THEN
    rBreakers[B10_1].Control.Trip := B10_1_Trip;
END_IF;

IF B10_1_Close THEN
    rBreakers[B10_1].Status.Closed := TRUE;
    rBreakers[B10_1].Status.Opened := FALSE;
ELSIF B10_1_Trip THEN
    rBreakers[B10_1].Status.Closed := FALSE;
    rBreakers[B10_1].Status.Opened := TRUE;
END_IF;

// Breaker B10_2
IF rBreakers[B10_2].Control.Close <> B10_2_Close THEN
    rBreakers[B10_2].Control.Close := B10_2_Close;
END_IF;
IF rBreakers[B10_2].Control.Trip <> B10_2_Trip THEN
    rBreakers[B10_2].Control.Trip := B10_2_Trip;
END_IF;

IF B10_2_Close THEN
    rBreakers[B10_2].Status.Closed := TRUE;
    rBreakers[B10_2].Status.Opened := FALSE;
ELSIF B10_2_Trip THEN
    rBreakers[B10_2].Status.Closed := FALSE;
    rBreakers[B10_2].Status.Opened := TRUE;
END_IF;

// Breaker B10_12
IF rBreakers[B10_12].Control.Close <> B10_12_Close THEN
    rBreakers[B10_12].Control.Close := B10_12_Close;
END_IF;
IF rBreakers[B10_12].Control.Trip <> B10_12_Trip THEN
    rBreakers[B10_12].Control.Trip := B10_12_Trip;
END_IF;

IF B10_12_Close THEN
    rBreakers[B10_12].Status.Closed := TRUE;
    rBreakers[B10_12].Status.Opened := FALSE;
ELSIF B10_12_Trip THEN
    rBreakers[B10_12].Status.Closed := FALSE;
    rBreakers[B10_12].Status.Opened := TRUE;
END_IF;

// Breaker B54
IF rBreakers[B54].Control.Close <> B54_Close THEN
    rBreakers[B54].Control.Close := B54_Close;
END_IF;
IF rBreakers[B54].Control.Trip <> B54_Trip THEN
    rBreakers[B54].Control.Trip := B54_Trip;
END_IF;

IF B54_Close THEN
    rBreakers[B54].Status.Closed := TRUE;
    rBreakers[B54].Status.Opened := FALSE;
ELSIF B54_Trip THEN
    rBreakers[B54].Status.Closed := FALSE;
    rBreakers[B54].Status.Opened := TRUE;
END_IF;

// Breaker B55
IF rBreakers[B55].Control.Close <> B55_Close THEN
    rBreakers[B55].Control.Close := B55_Close;
END_IF;
IF rBreakers[B55].Control.Trip <> B55_Trip THEN
    rBreakers[B55].Control.Trip := B55_Trip;
END_IF;

IF B55_Close THEN
    rBreakers[B55].Status.Closed := TRUE;
    rBreakers[B55].Status.Opened := FALSE;
ELSIF B55_Trip THEN
    rBreakers[B55].Status.Closed := FALSE;
    rBreakers[B55].Status.Opened := TRUE;
END_IF;

// Breaker B56
IF rBreakers[B56].Control.Close <> B56_Close THEN
    rBreakers[B56].Control.Close := B56_Close;
END_IF;
IF rBreakers[B56].Control.Trip <> B56_Trip THEN
    rBreakers[B56].Control.Trip := B56_Trip;
END_IF;

IF B56_Close THEN
    rBreakers[B56].Status.Closed := TRUE;
    rBreakers[B56].Status.Opened := FALSE;
ELSIF B56_Trip THEN
    rBreakers[B56].Status.Closed := FALSE;
    rBreakers[B56].Status.Opened := TRUE;
END_IF;

// Breaker B57
IF rBreakers[B57].Control.Close <> B57_Close THEN
    rBreakers[B57].Control.Close := B57_Close;
END_IF;
IF rBreakers[B57].Control.Trip <> B57_Trip THEN
    rBreakers[B57].Control.Trip := B57_Trip;
END_IF;

IF B57_Close THEN
    rBreakers[B57].Status.Closed := TRUE;
    rBreakers[B57].Status.Opened := FALSE;
ELSIF B57_Trip THEN
    rBreakers[B57].Status.Closed := FALSE;
    rBreakers[B57].Status.Opened := TRUE;
END_IF;

// Step 2: Calculate intermediate conditions
bCondition_1A := (rBreakers[B10_12].Status.Closed AND rBreakers[B10_1].Status.Closed) OR rBreakers[B10_2].Status.Closed;
bCondition_2A := (rBreakers[B10_12].Status.Closed AND rBreakers[B10_2].Status.Closed) OR rBreakers[B10_1].Status.Closed;

// Step 3: Calculate output points
// Point_1a
IF rBreakers[B54].Status.Closed AND bCondition_1A THEN
    rPoints.Point_1a := 0;
ELSE
    rPoints.Point_1a := 138;
END_IF;

// Point_2a
IF rBreakers[B55].Status.Closed AND bCondition_1A THEN
    rPoints.Point_2a := 0;
ELSE
    rPoints.Point_2a := 138;
END_IF;

// Point_3a
IF rBreakers[B56].Status.Closed AND bCondition_2A THEN
    rPoints.Point_3a := 0;
ELSE
    rPoints.Point_3a := 138;
END_IF;

// Point_4a
IF rBreakers[B57].Status.Closed AND bCondition_2A THEN
    rPoints.Point_4a := 0;
ELSE
    rPoints.Point_4a := 138;
END_IF;

// Step 4: Map internal data to public outputs
Point_1a := rPoints.Point_1a;
Point_2a := rPoints.Point_2a;
Point_3a := rPoints.Point_3a;
Point_4a := rPoints.Point_4a;

B10_1_Opened := rBreakers[B10_1].Status.Opened;
B10_1_Closed := rBreakers[B10_1].Status.Closed;
B10_2_Opened := rBreakers[B10_2].Status.Opened;
B10_2_Closed := rBreakers[B10_2].Status.Closed;
B10_12_Opened := rBreakers[B10_12].Status.Opened;
B10_12_Closed := rBreakers[B10_12].Status.Closed;
B54_Opened := rBreakers[B54].Status.Opened;
B54_Closed := rBreakers[B54].Status.Closed;
B55_Opened := rBreakers[B55].Status.Opened;
B55_Closed := rBreakers[B55].Status.Closed;
B56_Opened := rBreakers[B56].Status.Opened;
B56_Closed := rBreakers[B56].Status.Closed;
B57_Opened := rBreakers[B57].Status.Opened;
B57_Closed := rBreakers[B57].Status.Closed;

// Step 5: Initialize internal placeholder variables (as per original spec)
SEL86_OUT := 0;
MOVE89_OUT := 0;
SEL66_OUT := 0;
MOVE69_OUT := 0;
SEL96_OUT := 0;
MOVE99_OUT := 0;
SEL106_OUT := 0;
MOVE109_OUT := 0;

END_FUNCTION_BLOCK