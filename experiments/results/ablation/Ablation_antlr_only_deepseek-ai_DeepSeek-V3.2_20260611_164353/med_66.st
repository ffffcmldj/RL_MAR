(* ============================================================
   Elevator Control System FUNCTION_BLOCK
   IEC 61131-3 Structured Text Implementation
   
   Description: Controls elevator movement and door operations
   based on current position, requested position, and button press.
   
   Features:
   - Manages motor direction (up/down/stop)
   - Controls door state (open/closed)
   - Responds to new requests during motion
   - Ensures safety: door closed during movement
   - Prevents simultaneous motor activation
   ============================================================ *)

FUNCTION_BLOCK ElevatorControl
VAR_INPUT
    CurrentPos : INT;          (* Current floor position *)
    RequestedPos : INT;        (* Target floor requested *)
    ButtonPressed : BOOL;      (* Button press trigger *)
END_VAR

VAR_OUTPUT
    MotorMovingUp : BOOL;      (* TRUE when moving upward *)
    MotorMovingDown : BOOL;    (* TRUE when moving downward *)
    DoorIsOpen : BOOL;         (* TRUE when door is open *)
END_VAR

VAR
    (* Internal state management *)
    InternalState : INT := 0;  (* 0: Idle, 1: Moving Up, 2: Moving Down *)
    LastRequestedPos : INT := 0;
    ButtonPressedRisingEdge : BOOL;
    PreviousButtonPressed : BOOL := FALSE;
END_VAR

(* Rising edge detection for button press *)
ButtonPressedRisingEdge := ButtonPressed AND NOT PreviousButtonPressed;

(* Main state machine *)
CASE InternalState OF
    0: (* IDLE STATE - Elevator stationary at floor *)
        MotorMovingUp := FALSE;
        MotorMovingDown := FALSE;
        DoorIsOpen := TRUE;
        
        (* Process button press in idle state *)
        IF ButtonPressedRisingEdge THEN
            LastRequestedPos := RequestedPos;
            
            (* Determine direction and transition *)
            IF RequestedPos > CurrentPos THEN
                DoorIsOpen := FALSE;
                InternalState := 1;  (* Move to Moving Up state *)
            ELSIF RequestedPos < CurrentPos THEN
                DoorIsOpen := FALSE;
                InternalState := 2;  (* Move to Moving Down state *)
            ELSE
                (* Already at requested floor - stay idle with door open *)
                DoorIsOpen := TRUE;
                InternalState := 0;
            END_IF;
        END_IF;
        
    1: (* MOVING UP STATE *)
        (* Safety: Door must be closed during movement *)
        DoorIsOpen := FALSE;
        
        (* Check if target reached *)
        IF CurrentPos >= LastRequestedPos THEN
            (* Stop at target floor *)
            MotorMovingUp := FALSE;
            MotorMovingDown := FALSE;
            DoorIsOpen := TRUE;
            InternalState := 0;  (* Return to idle *)
        ELSE
            (* Continue moving up *)
            MotorMovingUp := TRUE;
            MotorMovingDown := FALSE;
            
            (* Process new requests during movement *)
            IF ButtonPressedRisingEdge THEN
                IF RequestedPos > LastRequestedPos THEN
                    (* New request is higher - update target *)
                    LastRequestedPos := RequestedPos;
                ELSIF RequestedPos < CurrentPos THEN
                    (* New request is in opposite direction - change direction *)
                    LastRequestedPos := RequestedPos;
                    DoorIsOpen := FALSE;
                    InternalState := 2;  (* Switch to Moving Down *)
                END_IF;
            END_IF;
        END_IF;
        
    2: (* MOVING DOWN STATE *)
        (* Safety: Door must be closed during movement *)
        DoorIsOpen := FALSE;
        
        (* Check if target reached *)
        IF CurrentPos <= LastRequestedPos THEN
            (* Stop at target floor *)
            MotorMovingUp := FALSE;
            MotorMovingDown := FALSE;
            DoorIsOpen := TRUE;
            InternalState := 0;  (* Return to idle *)
        ELSE
            (* Continue moving down *)
            MotorMovingUp := FALSE;
            MotorMovingDown := TRUE;
            
            (* Process new requests during movement *)
            IF ButtonPressedRisingEdge THEN
                IF RequestedPos < LastRequestedPos THEN
                    (* New request is lower - update target *)
                    LastRequestedPos := RequestedPos;
                ELSIF RequestedPos > CurrentPos THEN
                    (* New request is in opposite direction - change direction *)
                    LastRequestedPos := RequestedPos;
                    DoorIsOpen := FALSE;
                    InternalState := 1;  (* Switch to Moving Up *)
                END_IF;
            END_IF;
        END_IF;
        
END_CASE;

(* Store button state for rising edge detection *)
PreviousButtonPressed := ButtonPressed;

END_FUNCTION_BLOCK;