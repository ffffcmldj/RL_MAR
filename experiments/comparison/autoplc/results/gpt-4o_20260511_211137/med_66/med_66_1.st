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
    END_VAR

    // Initialization: Start with the elevator in the Idle State
    MotorMovingUp := FALSE;
    MotorMovingDown := FALSE;
    DoorIsOpen := TRUE;

    // Button Press Handling
    IF ButtonPressed THEN
        // Determine the direction of movement based on requested position
        IF RequestedPos > CurrentPos THEN
            // Transition to Moving Up State
            MotorMovingUp := TRUE;
            MotorMovingDown := FALSE;
            DoorIsOpen := FALSE;
        ELSIF RequestedPos < CurrentPos THEN
            // Transition to Moving Down State
            MotorMovingUp := FALSE;
            MotorMovingDown := TRUE;
            DoorIsOpen := FALSE;
        END_IF;
    END_IF;

    // Movement Logic
    IF MotorMovingUp THEN
        // Simulate movement up
        IF CurrentPos < RequestedPos THEN
            CurrentPos := CurrentPos + 1; // Move up one floor
        ELSE
            // Arrival at Requested Floor
            MotorMovingUp := FALSE;
            DoorIsOpen := TRUE;
        END_IF;
    ELSIF MotorMovingDown THEN
        // Simulate movement down
        IF CurrentPos > RequestedPos THEN
            CurrentPos := CurrentPos - 1; // Move down one floor
        ELSE
            // Arrival at Requested Floor
            MotorMovingDown := FALSE;
            DoorIsOpen := TRUE;
        END_IF;
    END_IF;

    // Responsiveness to Position Changes
    IF (MotorMovingUp OR MotorMovingDown) AND (RequestedPos <> CurrentPos) THEN
        // Re-evaluate direction if requested position changes
        IF RequestedPos > CurrentPos THEN
            MotorMovingUp := TRUE;
            MotorMovingDown := FALSE;
        ELSIF RequestedPos < CurrentPos THEN
            MotorMovingUp := FALSE;
            MotorMovingDown := TRUE;
        END_IF;
    END_IF;

END_FUNCTION_BLOCK