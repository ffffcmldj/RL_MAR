START_REASON
The previous code failed the CODESYS compiler validation with the error "应该用';' 替换'IF'" (Should replace 'IF' with ';'). This is a specific syntax error in the CODESYS dialect of Structured Text (ST).

**Root Cause Analysis:**
1.  **Missing Semicolons in `CASE` Statements**: In the `CASE CurrentState OF` block, the statements following the colon (e.g., `1: MotorMovingUp := TRUE;`) were missing the terminating semicolon `;` at the end of the line. While some parsers might be lenient, the CODESYS compiler strictly requires a semicolon after every executable statement, including assignments inside a `CASE` block.
2.  **Logic Verification**: The logic for state transitions and direction calculation was corrected in the previous step (using explicit `IF/ELSE` instead of arithmetic), which is good. However, the syntax error in the `CASE` block is the immediate blocker.
3.  **Variable Initialization**: The `VAR` section initialization using `:=` is correct for `FUNCTION_BLOCK` variables.
4.  **Structure**: The `FUNCTION_BLOCK` structure with `VAR_INPUT`, `VAR_OUTPUT`, `VAR`, and `BEGIN`...`END_FUNCTION_BLOCK` is correct.

**Fix Plan:**
1.  Add semicolons `;` to the end of every assignment statement within the `CASE` block.
2.  Ensure all other statements (like `IF/END_IF`) also have semicolons where missing (though the previous draft mostly had them, the `CASE` block was the culprit).
3.  Maintain the corrected logic for state transitions.

END_REASON

START_ST
FUNCTION_BLOCK ElevatorControl
VAR_INPUT
    CurrentPos : INT;
    RequestedPos : INT;
    ButtonPressed : BOOL;
END_VAR
VAR_OUTPUT
    MotorMovingUp : BOOL;
    MotorMovingDown : BOOL;
    DoorIsOpen : BOOL;
END_VAR
VAR
    CurrentState : INT := 0; // 0:IDLE, 1:MOVING_UP, 2:MOVING_DOWN, 3:STOPPED_AT_FLOOR
    PreviousButtonPressed : BOOL := FALSE; // For rising edge detection
    Direction : INT := 0; // 1: Up, -1: Down, 0: None
END_VAR

BEGIN
    (* --- 1. BUTTON PRESS DETECTION (RISING EDGE) --- *)
    (* Detect if the button was just pressed to trigger a state change *)
    IF ButtonPressed AND NOT PreviousButtonPressed THEN
        (* Button was just pressed *)
        Direction := 0; (* Reset direction *)
        
        (* Determine initial direction based on position difference *)
        IF RequestedPos > CurrentPos THEN
            Direction := 1; (* Requesting Up *)
        ELSIF RequestedPos < CurrentPos THEN
            Direction := -1; (* Requesting Down *)
        END_IF;
    END_IF;
    
    (* Update previous button state for next cycle *)
    PreviousButtonPressed := ButtonPressed;

    (* --- 2. STATE MACHINE LOGIC --- *)
    
    (* STATE 0: IDLE (WAITING) *)
    IF CurrentState = 0 THEN
        (* If button was just pressed and a direction was determined *)
        IF Direction <> 0 THEN
            IF Direction = 1 THEN
                CurrentState := 1; (* Move Up *)
            ELSIF Direction = -1 THEN
                CurrentState := 2; (* Move Down *)
            END_IF;
        END_IF;
    END_IF;

    (* STATE 1: MOVING UP *)
    IF CurrentState = 1 THEN
        IF RequestedPos = CurrentPos THEN
            (* Reached target *)
            CurrentState := 3; (* Transition to STOPPED_AT_FLOOR *)
        END_IF;
    END_IF;

    (* STATE 2: MOVING DOWN *)
    IF CurrentState = 2 THEN
        IF RequestedPos = CurrentPos THEN
            (* Reached target *)
            CurrentState := 3; (* Transition to STOPPED_AT_FLOOR *)
        END_IF;
    END_IF;

    (* STATE 3: STOPPED AT FLOOR *)
    IF CurrentState = 3 THEN
        (* If button is pressed again, decide new direction *)
        IF ButtonPressed THEN
            IF RequestedPos > CurrentPos THEN
                CurrentState := 1; (* Move Up *)
                Direction := 1;
            ELSIF RequestedPos < CurrentPos THEN
                CurrentState := 2; (* Move Down *)
                Direction := -1;
            END_IF;
        END_IF;
        (* If ButtonPressed is FALSE, remain in State 3 (Door Open) *)
    END_IF;

    (* --- 3. OUTPUT ASSIGNMENT --- *)
    
    (* Reset outputs *)
    MotorMovingUp := FALSE;
    MotorMovingDown := FALSE;
    DoorIsOpen := FALSE;

    (* Assign based on CurrentState *)
    CASE CurrentState OF
        0: (* IDLE *)
            DoorIsOpen := FALSE;
            
        1: (* MOVING UP *)
            MotorMovingUp := TRUE;
            MotorMovingDown := FALSE;
            DoorIsOpen := FALSE; (* Moving -> Door Closed *)
            
        2: (* MOVING DOWN *)
            MotorMovingUp := FALSE;
            MotorMovingDown := TRUE;
            DoorIsOpen := FALSE; (* Moving -> Door Closed *)
            
        3: (* STOPPED AT FLOOR *)
            MotorMovingUp := FALSE;
            MotorMovingDown := FALSE;
            DoorIsOpen := TRUE; (* Stationary at target -> Door Open *)
    END_CASE;

END_FUNCTION_BLOCK
END_ST