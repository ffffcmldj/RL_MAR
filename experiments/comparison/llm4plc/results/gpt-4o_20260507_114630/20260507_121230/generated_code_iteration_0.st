scl
START_ST
FUNCTION_BLOCK ElevatorControl
VAR_INPUT
    CurrentPos : INT; // The current floor where the elevator is located
    RequestedPos : INT; // The target floor where the user wants the elevator to go
    ButtonPressed : BOOL; // A signal indicating that the button has been pressed
END_VAR
VAR_OUTPUT
    MotorMovingUp : BOOL; // A signal indicating that the elevator motor is moving upwards
    MotorMovingDown : BOOL; // A signal indicating that the elevator motor is moving downwards
    DoorIsOpen : BOOL; // A signal indicating that the elevator door is open
END_VAR
VAR
    state : INT := 0; // The current state of the elevator (0 = IDLE, 1 = MOVING_UP, 2 = MOVING_DOWN)
    prevState : INT := 0; // The previous state of the elevator
    MotorStationary : BOOL := TRUE; // Indicates whether the motor is stationary
END_VAR

// Elevator control logic
IF state = 0 THEN // IDLE state
    MotorMovingUp := FALSE;
    MotorMovingDown := FALSE;
    DoorIsOpen := TRUE;
    MotorStationary := TRUE;

    // Transition to MOVING_UP or MOVING_DOWN based on input
    IF ButtonPressed THEN
        IF RequestedPos > CurrentPos THEN
            state := 1; // Transition to MOVING_UP
        ELSIF RequestedPos < CurrentPos THEN
            state := 2; // Transition to MOVING_DOWN
        END_IF;
    END_IF;

ELSIF state = 1 THEN // MOVING_UP state
    MotorMovingUp := TRUE;
    MotorMovingDown := FALSE;
    DoorIsOpen := FALSE;
    MotorStationary := FALSE;

    // Transition to IDLE when the requested floor is reached
    IF CurrentPos = RequestedPos THEN
        state := 0; // Transition to IDLE
    END_IF;

ELSIF state = 2 THEN // MOVING_DOWN state
    MotorMovingUp := FALSE;
    MotorMovingDown := TRUE;
    DoorIsOpen := FALSE;
    MotorStationary := FALSE;

    // Transition to IDLE when the requested floor is reached
    IF CurrentPos = RequestedPos THEN
        state := 0; // Transition to IDLE
    END_IF;

END_IF;

// Store the previous state for debugging or logging purposes
prevState := state;

END_FUNCTION_BLOCK
END_ST