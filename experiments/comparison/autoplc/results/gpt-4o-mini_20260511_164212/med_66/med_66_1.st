FUNCTION_BLOCK ElevatorControl
    VAR_INPUT
        CurrentPos : INT;      // The current floor where the elevator is located
        RequestedPos : INT;    // The target floor where the user wants the elevator to go
        ButtonPressed : BOOL;   // A signal indicating that the button has been pressed
    END_VAR

    VAR_OUTPUT
        MotorMovingUp : BOOL;   // A signal indicating that the elevator motor is moving upwards
        MotorMovingDown : BOOL;  // A signal indicating that the elevator motor is moving downwards
        DoorIsOpen : BOOL;       // A signal indicating that the elevator door is open
    END_VAR

    VAR
        MotorStationary : BOOL := TRUE; // Indicates if the elevator is stationary
    END_VAR

    // Initialize outputs
    MotorMovingUp := FALSE;
    MotorMovingDown := FALSE;
    DoorIsOpen := TRUE; // Door is open when stationary

    // Main control logic
    IF ButtonPressed THEN
        // Close the door when the button is pressed
        DoorIsOpen := FALSE;

        // Determine the direction of movement
        IF RequestedPos > CurrentPos THEN
            MotorMovingUp := TRUE;
            MotorMovingDown := FALSE;
        ELSIF RequestedPos < CurrentPos THEN
            MotorMovingUp := FALSE;
            MotorMovingDown := TRUE;
        END_IF;
    END_IF;

    // Check if the elevator is moving
    IF MotorMovingUp OR MotorMovingDown THEN
        // Ensure the door remains closed while moving
        DoorIsOpen := FALSE;

        // Check if the elevator has reached the requested position
        IF CurrentPos = RequestedPos THEN
            // Stop the elevator and open the door
            MotorMovingUp := FALSE;
            MotorMovingDown := FALSE;
            DoorIsOpen := TRUE;
        END_IF;
    ELSE
        // If the elevator is stationary, keep the door open
        IF NOT ButtonPressed THEN
            DoorIsOpen := TRUE;
        END_IF;
    END_IF;

END_FUNCTION_BLOCK