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
            CurrentState := 1 + (Direction + 1) / 2; 
            (* If Direction=1 (Up), State becomes 1. If Direction=-1 (Down), State becomes 2 *)
        END_IF;
        
        (* If no direction requested or button not pressed, remain in IDLE *)
        (* Note: If RequestedPos == CurrentPos while idle, we stay in IDLE until button press to open door *)
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
            (* Stationary but not at target (or just arrived and waiting for next call) *)
            (* Prompt: "open when stationary at the requested floor". 
               If we are in IDLE, we are not necessarily at the requested floor unless RequestedPos==CurrentPos.
               However, if RequestedPos==CurrentPos and we are in IDLE, we should open door.
               But our FSM logic transitions to State 3 immediately upon arrival.
               So State 0 implies we are NOT at the target floor yet, or waiting for a new command.
               Safety: Door Closed. *)
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