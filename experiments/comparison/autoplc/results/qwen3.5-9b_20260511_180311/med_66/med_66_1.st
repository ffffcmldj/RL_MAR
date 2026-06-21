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

IF CurrentPos = RequestedPos THEN
    MotorMovingUp := FALSE;
    MotorMovingDown := FALSE;
    MotorStationary := TRUE;
    DoorIsOpen := TRUE;
ELSIF ButtonPressed = TRUE AND MotorStationary = TRUE THEN
    MotorStationary := FALSE;
    IF RequestedPos > CurrentPos THEN
        MotorMovingUp := TRUE;
        MotorMovingDown := FALSE;
    ELSIF RequestedPos < CurrentPos THEN
        MotorMovingUp := FALSE;
        MotorMovingDown := TRUE;
    END_IF;
    DoorIsOpen := FALSE;
ELSE
    IF MotorStationary = FALSE THEN
        IF RequestedPos > CurrentPos THEN
            MotorMovingUp := TRUE;
            MotorMovingDown := FALSE;
        ELSIF RequestedPos < CurrentPos THEN
            MotorMovingUp := FALSE;
            MotorMovingDown := TRUE;
        END_IF;
        DoorIsOpen := FALSE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK