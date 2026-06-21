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
    CurrentState : INT := 0;  (* 0=Idle, 1=MovingUp, 2=MovingDown, 3=Arrived *)
    NextState : INT := 0;
END_VAR

(* State machine implementation *)
CASE CurrentState OF
    0: (* Idle State *)
        (* State actions *)
        MotorMovingUp := FALSE;
        MotorMovingDown := FALSE;
        DoorIsOpen := TRUE;
        
        (* Transition logic *)
        IF ButtonPressed THEN
            IF RequestedPos > CurrentPos THEN
                NextState := 1;  (* Move up *)
            ELSIF RequestedPos < CurrentPos THEN
                NextState := 2;  (* Move down *)
            ELSE
                NextState := 3;  (* Already at requested floor *)
            END_IF;
        ELSE
            NextState := 0;  (* Remain idle *)
        END_IF;
        
    1: (* MovingUp State *)
        (* State actions *)
        MotorMovingUp := TRUE;
        MotorMovingDown := FALSE;
        DoorIsOpen := FALSE;
        
        (* Transition logic *)
        IF CurrentPos = RequestedPos THEN
            NextState := 3;  (* Arrived at target floor *)
        ELSIF RequestedPos < CurrentPos THEN
            NextState := 2;  (* Switch to moving down if new request is below *)
        ELSE
            NextState := 1;  (* Continue moving up *)
        END_IF;
        
    2: (* MovingDown State *)
        (* State actions *)
        MotorMovingUp := FALSE;
        MotorMovingDown := TRUE;
        DoorIsOpen := FALSE;
        
        (* Transition logic *)
        IF CurrentPos = RequestedPos THEN
            NextState := 3;  (* Arrived at target floor *)
        ELSIF RequestedPos > CurrentPos THEN
            NextState := 1;  (* Switch to moving up if new request is above *)
        ELSE
            NextState := 2;  (* Continue moving down *)
        END_IF;
        
    3: (* Arrived State *)
        (* State actions *)
        MotorMovingUp := FALSE;
        MotorMovingDown := FALSE;
        DoorIsOpen := TRUE;
        
        (* Transition logic *)
        IF ButtonPressed THEN
            IF RequestedPos > CurrentPos THEN
                NextState := 1;  (* Move up *)
            ELSIF RequestedPos < CurrentPos THEN
                NextState := 2;  (* Move down *)
            ELSE
                NextState := 3;  (* Stay arrived *)
            END_IF;
        ELSE
            NextState := 3;  (* Remain arrived *)
        END_IF;
        
END_CASE;

(* Update state for next cycle *)
CurrentState := NextState;

END_FUNCTION_BLOCK