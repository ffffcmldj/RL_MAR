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
    bMovementInitiated : BOOL := FALSE;
END_VAR

(* Main logic body begins here *)

(* Reset outputs on each cycle *)
MotorMovingUp := FALSE;
MotorMovingDown := FALSE;
DoorIsOpen := FALSE;

(* Handle button press to initiate movement *)
IF ButtonPressed THEN
    bMovementInitiated := TRUE;
    DoorIsOpen := FALSE;
END_IF;

(* Determine movement direction and handle state transitions *)
IF bMovementInitiated THEN
    IF CurrentPos < RequestedPos THEN
        (* Move up *)
        MotorMovingUp := TRUE;
        MotorMovingDown := FALSE;
        DoorIsOpen := FALSE;
    ELSIF CurrentPos > RequestedPos THEN
        (* Move down *)
        MotorMovingUp := FALSE;
        MotorMovingDown := TRUE;
        DoorIsOpen := FALSE;
    ELSE
        (* Reached destination *)
        MotorMovingUp := FALSE;
        MotorMovingDown := FALSE;
        DoorIsOpen := TRUE;
        bMovementInitiated := FALSE;
    END_IF;
ELSE
    (* Stationary at requested floor *)
    IF CurrentPos = RequestedPos THEN
        DoorIsOpen := TRUE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK;