START_ST
FUNCTION_BLOCK TrafficManagementSystem
VAR_INPUT
    VehicleCount1 : INT;
    VehicleCount2 : INT;
    VehicleCount3 : INT;
    VehicleCount4 : INT;
END_VAR

VAR_OUTPUT
    TrafficLight1 : BOOL;
    TrafficLight2 : BOOL;
    TrafficLight3 : BOOL;
    TrafficLight4 : BOOL;
END_VAR

VAR
    CurrentState : INT;
    TempLight1 : BOOL;
    TempLight2 : BOOL;
    TempLight3 : BOOL;
    TempLight4 : BOOL;
    PrevLight1 : BOOL;
    PrevLight2 : BOOL;
    PrevLight3 : BOOL;
    PrevLight4 : BOOL;
END_VAR

BEGIN
    (* STATE 0: INITIALIZE / HOLD *)
    (* Purpose: Maintain the current light configuration. *)
    (* Action: No change to outputs unless a transition condition is met. *)
    (* In this continuous logic, we initialize state to 0 on first execution or reset if needed, *)
    (* but primarily rely on sequential execution for atomicity. *)
    IF CurrentState = 0 THEN
        (* State 0 Logic: Prepare for decision cycle *)
        CurrentState := 1;
    END_IF;

    (* STATE 1: DECIDE PAIR A (Intersections 1 & 2) *)
    (* Purpose: Compare VehicleCount1 vs VehicleCount2. *)
    (* Action: Determine which light (1 or 2) should be Green based on the higher count. *)
    IF CurrentState = 1 THEN
        (* Logic: If Count1 > Count2 -> Light1 = TRUE, Light2 = FALSE. *)
        IF VehicleCount1 > VehicleCount2 THEN
            TempLight1 := TRUE;
            TempLight2 := FALSE;
        (* Logic: If Count2 > Count1 -> Light1 = FALSE, Light2 = TRUE. *)
        ELSEIF VehicleCount2 > VehicleCount1 THEN
            TempLight1 := FALSE;
            TempLight2 := TRUE;
        (* Logic: If Count1 = Count2 -> Retain previous state (or default to previous to avoid flicker). *)
        ELSE
            TempLight1 := PrevLight1;
            TempLight2 := PrevLight2;
        END_IF;

        (* Transition to Decision Phase B *)
        CurrentState := 2;
    END_IF;

    (* STATE 2: DECIDE PAIR B (Intersections 3 & 4) *)
    (* Purpose: Compare VehicleCount3 vs VehicleCount4. *)
    (* Action: Determine which light (3 or 4) should be Green based on the higher count. *)
    IF CurrentState = 2 THEN
        (* Logic: If Count3 > Count4 -> Light3 = TRUE, Light4 = FALSE. *)
        IF VehicleCount3 > VehicleCount4 THEN
            TempLight3 := TRUE;
            TempLight4 := FALSE;
        (* Logic: If Count4 > Count3 -> Light3 = FALSE, Light4 = TRUE. *)
        ELSEIF VehicleCount4 > VehicleCount3 THEN
            TempLight3 := FALSE;
            TempLight4 := TRUE;
        (* Logic: If Count3 = Count4 -> Retain previous state. *)
        ELSE
            TempLight3 := PrevLight3;
            TempLight4 := PrevLight4;
        END_IF;

        (* Transition to Hold (State 0) for next cycle *)
        CurrentState := 0;
    END_IF;

    (* Update Previous Lights for the next equality check *)
    PrevLight1 := TempLight1;
    PrevLight2 := TempLight2;
    PrevLight3 := TempLight3;
    PrevLight4 := TempLight4;

    (* Assign calculated values to actual outputs *)
    TrafficLight1 := TempLight1;
    TrafficLight2 := TempLight2;
    TrafficLight3 := TempLight3;
    TrafficLight4 := TempLight4;

END_FUNCTION_BLOCK
END_ST