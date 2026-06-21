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

(* Main elevator control logic *)
IF ButtonPressed THEN
    (* Close door when button is pressed *)
    DoorIsOpen := FALSE;
    
    (* Determine movement direction based on position comparison *)
    IF RequestedPos > CurrentPos THEN
        MotorMovingUp := TRUE;
        MotorMovingDown := FALSE;
        bMoving := TRUE;
    ELSIF RequestedPos < CurrentPos THEN
        MotorMovingUp := FALSE;
        MotorMovingDown := TRUE;
        bMoving := TRUE;
    ELSE
        (* Already at requested floor *)
        MotorMovingUp := FALSE;
        MotorMovingDown := FALSE;
        bMoving := FALSE;
        DoorIsOpen := TRUE;
    END_IF;
END_IF;

(* Stop and open door when reaching requested floor *)
IF CurrentPos = RequestedPos AND bMoving THEN
    MotorMovingUp := FALSE;
    MotorMovingDown := FALSE;
    bMoving := FALSE;
    DoorIsOpen := TRUE;
END_IF;

(* Ensure door remains closed while moving *)
IF bMoving THEN
    DoorIsOpen := FALSE;
END_IF;

(* Safety: Ensure motor cannot move in both directions simultaneously *)
IF MotorMovingUp AND MotorMovingDown THEN
    MotorMovingUp := FALSE;
    MotorMovingDown := FALSE;
    bMoving := FALSE;
END_IF;

END_FUNCTION_BLOCK