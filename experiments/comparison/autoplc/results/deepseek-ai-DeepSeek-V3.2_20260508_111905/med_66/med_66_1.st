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
    MotorStationary : BOOL := TRUE;
    bButtonPressedPrev : BOOL := FALSE;
END_VAR

    // Detect rising edge of ButtonPressed
    IF ButtonPressed AND NOT bButtonPressedPrev THEN
        // Button was just pressed - close door and evaluate movement
        DoorIsOpen := FALSE;
        
        // Determine movement direction based on position comparison
        IF RequestedPos > CurrentPos THEN
            // Move up
            MotorMovingUp := TRUE;
            MotorMovingDown := FALSE;
            MotorStationary := FALSE;
        ELSIF RequestedPos < CurrentPos THEN
            // Move down
            MotorMovingUp := FALSE;
            MotorMovingDown := TRUE;
            MotorStationary := FALSE;
        ELSE
            // Already at requested position
            MotorMovingUp := FALSE;
            MotorMovingDown := FALSE;
            MotorStationary := TRUE;
            DoorIsOpen := TRUE;
        END_IF
    END_IF
    
    // Store previous button state for edge detection
    bButtonPressedPrev := ButtonPressed;
    
    // Check if elevator has reached requested position
    IF NOT MotorStationary THEN
        IF CurrentPos = RequestedPos THEN
            // Reached destination - stop motors and open door
            MotorMovingUp := FALSE;
            MotorMovingDown := FALSE;
            DoorIsOpen := TRUE;
            MotorStationary := TRUE;
        ELSE
            // Still moving - keep door closed
            DoorIsOpen := FALSE;
            
            // Update movement direction if RequestedPos changes during motion
            IF RequestedPos > CurrentPos THEN
                MotorMovingUp := TRUE;
                MotorMovingDown := FALSE;
            ELSIF RequestedPos < CurrentPos THEN
                MotorMovingUp := FALSE;
                MotorMovingDown := TRUE;
            END_IF
        END_IF
    END_IF
    
    // Ensure motor outputs are mutually exclusive
    IF MotorMovingUp AND MotorMovingDown THEN
        MotorMovingUp := FALSE;
        MotorMovingDown := FALSE;
    END_IF
    
    // Ensure door state is consistent with movement status
    IF MotorMovingUp OR MotorMovingDown THEN
        DoorIsOpen := FALSE;
    END_IF

END_FUNCTION_BLOCK