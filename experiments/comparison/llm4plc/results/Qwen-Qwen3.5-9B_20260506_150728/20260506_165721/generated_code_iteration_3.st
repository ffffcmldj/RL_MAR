START_REASON
The previous code failed the CODESYS compiler validation with the specific error: "应该用';' 替换'IF'" (Should replace 'IF' with ';').

Analysis of the error:
1.  **Syntax Error in State Machine Logic**: The previous code structure used `IF CurrentState = 0 THEN ... END_IF;` followed by `IF CurrentState = 2 THEN ... END_IF;`. While this is valid ST syntax for sequential execution, the specific error message suggests a parsing issue often caused by missing semicolons at the end of statements or blocks within the `BEGIN...END` section, or a specific dialect requirement where the compiler expects a statement terminator before the next `IF` keyword in certain contexts (though standard IEC 61131-3 allows `IF` after `END_IF`).
2.  **Missing Semicolons**: A common cause for "replace IF with ;" errors in automated validation tools is that a preceding statement (like an assignment or a block) was missing its terminating semicolon `;` immediately before the next `IF` statement. For example, `END_IF` must be followed by `;` if it is not the last statement in the block, or the assignment inside the block might be missing a `;`.
3.  **Variable Initialization**: The variables `Elevator1Position` and `Elevator2Position` were used in the logic but not explicitly initialized in the `VAR` section or the initialization block, which can sometimes cause type inference errors in strict compilers if not handled carefully, though less likely to cause this specific syntax error.
4.  **Correction Strategy**:
    *   Ensure every single statement ends with a semicolon `;`.
    *   Explicitly initialize `Elevator1Position` and `Elevator2Position` to 0 in the `VAR` section or initialization logic to avoid undefined behavior.
    *   Simplify the state machine logic to ensure clear separation and proper termination of every block.
    *   Add the missing semicolons after `END_IF` statements that are not at the very end of the `BEGIN` block.

END_REASON

START_ST
FUNCTION_BLOCK CarParkingSystem
VAR_INPUT
    NewCarSlot : INT;
END_VAR
VAR_OUTPUT
    Elevator1Busy : BOOL;
    Elevator2Busy : BOOL;
    Elevator1Position : INT;
    Elevator2Position : INT;
END_VAR
VAR
    (* FSM State Definitions *)
    CurrentState : INT := 0; (* 0:IDLE_SCAN, 1:ASSIGN_TARGET, 2:MOVE_ELEVATOR_1, 3:MOVE_ELEVATOR_2, 4:COMPLETE_TASK *)
    
    (* Target and Status Variables *)
    Elevator1Target : INT;
    Elevator2Target : INT;
    SlotOccupied : BOOL;
    TaskCompleted : BOOL;
    
    (* Parking Slot Status Array *)
    CarSlots : ARRAY[1..100] OF BOOL;
    
    (* Simulation Variables for Movement *)
    MoveDirectionE1 : INT;
    MoveDirectionE2 : INT;
    MoveStepE1 : BOOL;
    MoveStepE2 : BOOL;
    
    (* Initial Positions *)
    InitPosE1 : INT := 0;
    InitPosE2 : INT := 0;
END_VAR

BEGIN
    (* --- INITIALIZATION --- *)
    IF CurrentState = 0 THEN
        CurrentState := 0;
        Elevator1Target := 0;
        Elevator2Target := 0;
        MoveDirectionE1 := 0;
        MoveDirectionE2 := 0;
        MoveStepE1 := FALSE;
        MoveStepE2 := FALSE;
        Elevator1Position := InitPosE1;
        Elevator2Position := InitPosE2;
    END_IF;

    (* --- STATE 0: IDLE_SCAN --- *)
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
                Elevator2Target := Elevator2Position;
                CurrentState := 2; (* Transition to MOVE_ELEVATOR_1 *)
            ELSE
                (* Assign to Elevator 2 *)
                Elevator1Target := Elevator1Position;
                Elevator2Target := NewCarSlot;
                CurrentState := 3; (* Transition to MOVE_ELEVATOR_2 *)
            END_IF;
        END_IF;
        
        (* Check if any task is completed and return to idle *)
        IF Elevator1Busy = FALSE AND Elevator2Busy = FALSE THEN
            CurrentState := 0;
        END_IF;
    END_IF;

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

    (* --- STATE 1 & 4: HANDLED BY TRANSITIONS --- *)
    (* State 1 (Assign) and State 4 (Complete) are handled by the transitions 
       within State 0, 2, and 3. No separate execution block needed. *)

END_FUNCTION_BLOCK
END_ST