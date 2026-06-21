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
    bMoving : BOOL := FALSE;
END_VAR

// Main elevator control logic
IF ButtonPressed THEN
    // Start movement when button is pressed
    bMoving := TRUE;
    DoorIsOpen := FALSE;
END_IF;

IF bMoving THEN
    // Elevator is in motion
    IF RequestedPos > CurrentPos THEN
        // Move upward
        MotorMovingUp := TRUE;
        MotorMovingDown := FALSE;
        DoorIsOpen := FALSE;
    ELSIF RequestedPos < CurrentPos THEN
        // Move downward
        MotorMovingUp := FALSE;
        MotorMovingDown := TRUE;
        DoorIsOpen := FALSE;
    ELSE
        // Reached target floor
        MotorMovingUp := FALSE;
        MotorMovingDown := FALSE;
        DoorIsOpen := TRUE;
        bMoving := FALSE;
    END_IF;
ELSE
    // Elevator is stationary
    MotorMovingUp := FALSE;
    MotorMovingDown := FALSE;
    
    // Keep door open if at requested position, otherwise closed
    IF CurrentPos = RequestedPos THEN
        DoorIsOpen := TRUE;
    ELSE
        DoorIsOpen := FALSE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK