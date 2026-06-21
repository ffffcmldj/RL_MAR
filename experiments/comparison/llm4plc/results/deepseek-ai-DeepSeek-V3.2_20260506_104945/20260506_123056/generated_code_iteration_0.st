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
    state : INT := 0; (* 0: IDLE, 1: MOVING_UP, 2: MOVING_DOWN *)
    prevButtonPressed : BOOL := FALSE;
END_VAR

    (* Edge detection for ButtonPressed *)
    IF ButtonPressed AND NOT prevButtonPressed THEN
        (* Rising edge detected - evaluate transitions *)
        CASE state OF
            0: (* IDLE *)
                IF RequestedPos > CurrentPos THEN
                    state := 1; (* Move up *)
                ELSIF RequestedPos < CurrentPos THEN
                    state := 2; (* Move down *)
                END_IF;
                (* If RequestedPos = CurrentPos, remain in IDLE *)

            1: (* MOVING_UP *)
                IF RequestedPos < CurrentPos THEN
                    state := 2; (* Switch to moving down *)
                END_IF;

            2: (* MOVING_DOWN *)
                IF RequestedPos > CurrentPos THEN
                    state := 1; (* Switch to moving up *)
                END_IF;
        END_CASE;
    END_IF;

    (* Update previous button state *)
    prevButtonPressed := ButtonPressed;

    (* State machine outputs and internal transitions *)
    CASE state OF
        0: (* IDLE *)
            MotorMovingUp := FALSE;
            MotorMovingDown := FALSE;
            (* Door is open only if at requested floor *)
            DoorIsOpen := (CurrentPos = RequestedPos);

        1: (* MOVING_UP *)
            MotorMovingUp := TRUE;
            MotorMovingDown := FALSE;
            DoorIsOpen := FALSE;

            (* Check if reached target floor *)
            IF CurrentPos >= RequestedPos THEN
                state := 0; (* Stop at target *)
            END_IF;

        2: (* MOVING_DOWN *)
            MotorMovingUp := FALSE;
            MotorMovingDown := TRUE;
            DoorIsOpen := FALSE;

            (* Check if reached target floor *)
            IF CurrentPos <= RequestedPos THEN
                state := 0; (* Stop at target *)
            END_IF;
    END_CASE;

END_FUNCTION_BLOCK
END_ST