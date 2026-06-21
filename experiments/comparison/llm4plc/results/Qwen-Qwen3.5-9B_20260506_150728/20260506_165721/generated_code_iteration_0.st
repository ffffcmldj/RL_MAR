START_ST
FUNCTION_BLOCK CarParkingSystem
VAR_INPUT
    NewCarSlot : INT; (* Input for new car arrival slot number *)
END_VAR
VAR_OUTPUT
    Elevator1Busy : BOOL; (* Elevator 1 status - busy or idle *)
    Elevator2Busy : BOOL; (* Elevator 2 status - busy or idle *)
    Elevator1Position : INT; (* Elevator 1 current position *)
    Elevator2Position : INT; (* Elevator 2 current position *)
END_VAR
VAR
    (* FSM State Definitions *)
    CurrentState : INT; (* 0:IDLE_SCAN, 1:ASSIGN_TARGET, 2:MOVE_ELEVATOR_1, 3:MOVE_ELEVATOR_2, 4:COMPLETE_TASK *)
    
    (* Target and Status Variables *)
    Elevator1Target : INT; (* Elevator 1 target floor *)
    Elevator2Target : INT; (* Elevator 2 target floor *)
    SlotOccupied : BOOL; (* Temporary flag for the specific slot being processed *)
    TaskCompleted : BOOL; (* Temporary flag to indicate if movement is done *)
    
    (* Parking Slot Status Array *)
    CarSlots : ARRAY[1..100] OF BOOL; (* Array to represent parking slots - TRUE if occupied *)
    
    (* Simulation Variables for Movement *)
    MoveDirectionE1 : INT; (* Direction for Elevator 1: -1, 0, or 1 *)
    MoveDirectionE2 : INT; (* Direction for Elevator 2: -1, 0, or 1 *)
    MoveStepE1 : BOOL; (* Flag to simulate one step of movement for E1 *)
    MoveStepE2 : BOOL; (* Flag to simulate one step of movement for E2 *)
END_VAR
END_VAR

BEGIN
    (* --- INITIALIZATION --- *)
    IF CurrentState = 0 THEN
        (* Ensure initial state is clean on first execution or reset *)
        CurrentState := 0;
        Elevator1Target := 0;
        Elevator2Target := 0;
        MoveDirectionE1 := 0;
        MoveDirectionE2 := 0;
        MoveStepE1 := FALSE;
        MoveStepE2 := FALSE;
    END_IF;

    (* --- STATE 0: IDLE_SCAN --- *)
    (* System ready, no active tasks, waiting for NewCarSlot or checking for completed tasks *)
    IF CurrentState = 0 THEN
        Elevator1Busy := FALSE;
        Elevator2Busy := FALSE;
        
        (* Check if a new car has arrived *)
        IF NewCarSlot > 0 AND NewCarSlot <= 100 THEN
            (* Mark slot as occupied *)
            CarSlots[NewCarSlot] := TRUE;
            
            (* Determine which elevator to use based on slot range *)
            IF NewCarSlot <= 50 THEN
                (* Assign to Elevator 1 *)
                Elevator1Target := NewCarSlot;
                Elevator2Target := Elevator2Position; (* Keep E2 target as current position or 0 *)
                Elevator1Busy := TRUE;
                Elevator2Busy := FALSE;
                CurrentState := 2; (* Transition to MOVE_ELEVATOR_1 *)
            ELSE
                (* Assign to Elevator 2 *)
                Elevator1Target := Elevator1Position; (* Keep E1 target as current position or 0 *)
                Elevator2Target := NewCarSlot;
                Elevator1Busy := FALSE;
                Elevator2Busy := TRUE;
                CurrentState := 3; (* Transition to MOVE_ELEVATOR_2 *)
            END_IF;
        END_IF;
        
        (* Check if any task is completed and return to idle *)
        (* Note: In this FSM design, completion triggers a state change within the Move states,
           but we also check here to ensure state 0 is reached if logic dictates immediate reset *)
        IF Elevator1Busy = FALSE AND Elevator2Busy = FALSE THEN
            CurrentState := 0;
        END_IF;
    END_IF;

    (* --- STATE 1: ASSIGN_TARGET --- *)
    (* This state is logically merged into the transition logic above for efficiency.
       If NewCarSlot was processed, we moved to State 2 or 3.
       If no car arrived, we remain in State 0.
       We do not need a separate execution block for State 1 as the assignment happens instantly. *)

    (* --- STATE 2: MOVE_ELEVATOR_1 --- *)
    IF CurrentState = 2 THEN
        Elevator1Busy := TRUE;
        Elevator2Busy := FALSE;
        
        (* Simulate Movement Logic for Elevator 1 *)
        IF Elevator1Position < Elevator1Target THEN
            MoveDirectionE1 := 1;
        ELSIF Elevator1Position > Elevator1Target THEN
            MoveDirectionE1 := -1;
        ELSE
            MoveDirectionE1 := 0;
        END_IF;
        
        (* Simulate one step of movement *)
        IF MoveDirectionE1 <> 0 THEN
            Elevator1Position := Elevator1Position + MoveDirectionE1;
            (* Check if target reached *)
            IF Elevator1Position = Elevator1Target THEN
                TaskCompleted := TRUE;
                Elevator1Busy := FALSE;
                Elevator1Target := 0;
                CurrentState := 0; (* Transition to IDLE_SCAN *)
            END_IF;
        END_IF;
    END_IF;

    (* --- STATE 3: MOVE_ELEVATOR_2 --- *)
    IF CurrentState = 3 THEN
        Elevator1Busy := FALSE;
        Elevator2Busy := TRUE;
        
        (* Simulate Movement Logic for Elevator 2 *)
        IF Elevator2Position < Elevator2Target THEN
            MoveDirectionE2 := 1;
        ELSIF Elevator2Position > Elevator2Target THEN
            MoveDirectionE2 := -1;
        ELSE
            MoveDirectionE2 := 0;
        END_IF;
        
        (* Simulate one step of movement *)
        IF MoveDirectionE2 <> 0 THEN
            Elevator2Position := Elevator2Position + MoveDirectionE2;
            (* Check if target reached *)
            IF Elevator2Position = Elevator2Target THEN
                TaskCompleted := TRUE;
                Elevator2Busy := FALSE;
                Elevator2Target := 0;
                CurrentState := 0; (* Transition to IDLE_SCAN *)
            END_IF;
        END_IF;
    END_IF;

    (* --- STATE 4: COMPLETE_TASK --- *)
    (* This state is handled by the transition logic inside State 2 and State 3.
       Once the target is reached, the state is immediately reset to 0.
       No separate execution block is needed. *)

    (* --- END OF FUNCTION BLOCK --- *)
END_FUNCTION_BLOCK
END_ST