START_REASON
The previous CODESYS validation failed with "API call failed: 500". This generic error in the CODESYS compiler usually indicates a syntax error that prevents the parser from correctly structuring the code, often related to:
1.  **Missing `END_CASE`**: The `CASE` statement must be explicitly closed with `END_CASE`. The previous code used `END_CASE` but sometimes compilers are strict about the indentation or the presence of the keyword if the block is complex.
2.  **Variable Initialization Syntax**: In some strict ST dialects, initializing variables in the `VAR` section requires specific formatting or the use of `:=` only for constants, though `:=` for initial values is standard in IEC 61131-3. However, the most common cause for a generic "500" error in this context is a missing terminator for a control structure.
3.  **Missing `END_VAR`**: The `VAR` section in the previous code was closed correctly, but let's ensure the structure is perfectly aligned.
4.  **Logic Flow**: The logic `CurrentState := 1 + (Direction + 1) / 2` is mathematically correct for INT (1 -> 1, -1 -> 0? Wait. If Direction is -1: 1 + 0 / 2 = 1. This is a logic bug. If Direction is -1 (Down), State should be 2. The formula `1 + (-1+1)/2` = `1 + 0` = `1`. This maps Down to Up. This is a logic error causing incorrect behavior, though it might not trigger a compile error. I will fix the logic to be explicit: `IF Direction = 1 THEN CurrentState := 1 ELSE CurrentState := 2 END_IF`.
5.  **Missing `END_CASE`**: Looking closely at the previous code, the `CASE` block ends with `END_CASE`. This is correct.
6.  **Re-evaluating the "500" error**: Often, this happens if a `CASE` statement is missing its `END_CASE` or if there is a syntax error in the `VAR` initialization. Let's simplify the state transition logic to avoid arithmetic confusion and ensure all keywords are standard.
7.  **Critical Fix**: The logic `CurrentState := 1 + (Direction + 1) / 2` is definitely wrong for negative numbers in integer arithmetic (it results in 1 for -1). I will replace this with explicit `IF/ELSE` logic.
8.  **Compiler Strictness**: I will ensure the `CASE` statement is robust and all `END_VAR` tags are present.

The primary fix is correcting the state transition logic to avoid runtime logic errors and ensuring the syntax is 100% compliant with strict CODESYS parsers by removing potential ambiguity in the arithmetic expression for state assignment.
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
            (* Stationary but not at target or waiting for command *)
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