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
    b10_1_state : BOOL := FALSE;
    b10_2_state : BOOL := FALSE;
    b10_12_state : BOOL := FALSE;
    b54_state : BOOL := FALSE;
    b55_state : BOOL := FALSE;
    b56_state : BOOL := FALSE;
    b57_state : BOOL := FALSE;
END_VAR

(* Breaker B10_1 State Management *)
IF B10_1_Trip THEN
    b10_1_state := FALSE;
ELSIF B10_1_Close THEN
    b10_1_state := TRUE;
END_IF;

B10_1_Closed := b10_1_state;
B10_1_Opened := NOT b10_1_state;

(* Breaker B10_2 State Management *)
IF B10_2_Trip THEN
    b10_2_state := FALSE;
ELSIF B10_2_Close THEN
    b10_2_state := TRUE;
END_IF;

B10_2_Closed := b10_2_state;
B10_2_Opened := NOT b10_2_state;

(* Breaker B10_12 State Management *)
IF B10_12_Trip THEN
    b10_12_state := FALSE;
ELSIF B10_12_Close THEN
    b10_12_state := TRUE;
END_IF;

B10_12_Closed := b10_12_state;
B10_12_Opened := NOT b10_12_state;

(* Breaker B54 State Management *)
IF B54_Trip THEN
    b54_state := FALSE;
ELSIF B54_Close THEN
    b54_state := TRUE;
END_IF;

B54_Closed := b54_state;
B54_Opened := NOT b54_state;

(* Breaker B55 State Management *)
IF B55_Trip THEN
    b55_state := FALSE;
ELSIF B55_Close THEN
    b55_state := TRUE;
END_IF;

B55_Closed := b55_state;
B55_Opened := NOT b55_state;

(* Breaker B56 State Management *)
IF B56_Trip THEN
    b56_state := FALSE;
ELSIF B56_Close THEN
    b56_state := TRUE;
END_IF;

B56_Closed := b56_state;
B56_Opened := NOT b56_state;

(* Breaker B57 State Management *)
IF B57_Trip THEN
    b57_state := FALSE;
ELSIF B57_Close THEN
    b57_state := TRUE;
END_IF;

B57_Closed := b57_state;
B57_Opened := NOT b57_state;

(* Point Calculations *)
(* Point_1a: B54 closed AND ((B10_12 closed AND B10_1 closed) OR B10_2 closed) *)
IF b54_state AND ((b10_12_state AND b10_1_state) OR b10_2_state) THEN
    Point_1a := 0;
ELSE
    Point_1a := 138;
END_IF;

(* Point_2a: B55 closed AND ((B10_12 closed AND B10_1 closed) OR B10_2 closed) *)
IF b55_state AND ((b10_12_state AND b10_1_state) OR b10_2_state) THEN
    Point_2a := 0;
ELSE
    Point_2a := 138;
END_IF;

(* Point_3a: B56 closed AND ((B10_12 closed AND B10_2 closed) OR B10_1 closed) *)
IF b56_state AND ((b10_12_state AND b10_2_state) OR b10_1_state) THEN
    Point_3a := 0;
ELSE
    Point_3a := 138;
END_IF;

(* Point_4a: B57 closed AND ((B10_12 closed AND B10_2 closed) OR B10_1 closed) *)
IF b57_state AND ((b10_12_state AND b10_2_state) OR b10_1_state) THEN
    Point_4a := 0;
ELSE
    Point_4a := 138;
END_IF;

END_FUNCTION_BLOCK;