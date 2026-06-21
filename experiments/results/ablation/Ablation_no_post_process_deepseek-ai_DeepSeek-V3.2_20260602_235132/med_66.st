(*
    Elevator Control System Function Block
    Author: Senior PLC Commissioning Engineer
    Description: Controls elevator movement and door operations based on position requests
    Compliance: IEC 61131-3 Structured Text
*)

FUNCTION_BLOCK ElevatorControl
VAR_INPUT
    CurrentPos : INT;           (* Current floor position *)
    RequestedPos : INT;         (* Target floor position *)
    ButtonPressed : BOOL;       (* Button press trigger *)
END_VAR

VAR_OUTPUT
    MotorMovingUp : BOOL;       (* Elevator moving upward *)
    MotorMovingDown : BOOL;     (* Elevator moving downward *)
    DoorIsOpen : BOOL;          (* Door open status *)
END_VAR

VAR
    (* State machine enumeration *)
    State : (IDLE, MOVING_UP, MOVING_DOWN);
    
    (* Edge detection for button press *)
    PrevButtonPressed : BOOL := FALSE;
    
    (* Internal target storage for dynamic updates *)
    ActiveTarget : INT := 0;
    
    (* Safety flag to prevent simultaneous motor activation *)
    MotorActive : BOOL := FALSE;
END_VAR

(* Main state machine logic *)
CASE State OF
    IDLE:
        (* Stationary state - door open, motors off *)
        MotorMovingUp := FALSE;
        MotorMovingDown := FALSE;
        DoorIsOpen := TRUE;
        MotorActive := FALSE;
        
        (* Check for new button press with edge detection *)
        IF ButtonPressed AND NOT PrevButtonPressed THEN
            (* Store the requested position for dynamic updates *)
            ActiveTarget := RequestedPos;
            
            (* Determine movement direction *)
            IF ActiveTarget > CurrentPos THEN
                State := MOVING_UP;
                DoorIsOpen := FALSE;
                MotorMovingUp := TRUE;
                MotorActive := TRUE;
            ELSIF ActiveTarget < CurrentPos THEN
                State := MOVING_DOWN;
                DoorIsOpen := FALSE;
                MotorMovingDown := TRUE;
                MotorActive := TRUE;
            ELSE
                (* Already at target floor *)
                DoorIsOpen := TRUE;
                State := IDLE;
            END_IF;
        END_IF;
        
        (* Monitor for dynamic target updates while idle *)
        IF RequestedPos <> ActiveTarget AND ButtonPressed AND NOT PrevButtonPressed THEN
            ActiveTarget := RequestedPos;
        END_IF;
        
    MOVING_UP:
        (* Elevator moving upward *)
        MotorMovingUp := TRUE;
        MotorMovingDown := FALSE;
        DoorIsOpen := FALSE;
        MotorActive := TRUE;
        
        (* Check for dynamic target updates during movement *)
        IF RequestedPos <> ActiveTarget THEN
            ActiveTarget := RequestedPos;
            
            (* Re-evaluate direction if target changes *)
            IF ActiveTarget < CurrentPos THEN
                State := MOVING_DOWN;
            ELSIF ActiveTarget = CurrentPos THEN
                State := IDLE;
            END_IF;
        END_IF;
        
        (* Check if target floor reached *)
        IF CurrentPos >= ActiveTarget THEN
            (* Exact position check for safety *)
            IF CurrentPos = ActiveTarget THEN
                State := IDLE;
                MotorMovingUp := FALSE;
                DoorIsOpen := TRUE;
                MotorActive := FALSE;
            END_IF;
        END_IF;
        
    MOVING_DOWN:
        (* Elevator moving downward *)
        MotorMovingUp := FALSE;
        MotorMovingDown := TRUE;
        DoorIsOpen := FALSE;
        MotorActive := TRUE;
        
        (* Check for dynamic target updates during movement *)
        IF RequestedPos <> ActiveTarget THEN
            ActiveTarget := RequestedPos;
            
            (* Re-evaluate direction if target changes *)
            IF ActiveTarget > CurrentPos THEN
                State := MOVING_UP;
            ELSIF ActiveTarget = CurrentPos THEN
                State := IDLE;
            END_IF;
        END_IF;
        
        (* Check if target floor reached *)
        IF CurrentPos <= ActiveTarget THEN
            (* Exact position check for safety *)
            IF CurrentPos = ActiveTarget THEN
                State := IDLE;
                MotorMovingDown := FALSE;
                DoorIsOpen := TRUE;
                MotorActive := FALSE;
            END_IF;
        END_IF;
        
END_CASE;

(* Update button press history for edge detection *)
PrevButtonPressed := ButtonPressed;

(* Safety interlock: Ensure motors are never active simultaneously *)
IF MotorMovingUp AND MotorMovingDown THEN
    MotorMovingUp := FALSE;
    MotorMovingDown := FALSE;
    MotorActive := FALSE;
    State := IDLE;
END_IF;

END_FUNCTION_BLOCK