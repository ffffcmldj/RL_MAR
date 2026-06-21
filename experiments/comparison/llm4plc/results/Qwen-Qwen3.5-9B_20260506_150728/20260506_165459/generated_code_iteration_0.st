START_ST
FUNCTION_BLOCK WindowCleaningSystem
VAR_INPUT
    StartButton : BOOL;
    EmergencyStop : BOOL;
    UpperLimit : BOOL;
    LowerLimit : BOOL;
END_VAR
VAR_OUTPUT
    ElevatorUp : BOOL;
    ElevatorDown : BOOL;
    RotateClockwise : BOOL;
    WaterPump : BOOL;
END_VAR
VAR
    Current_State : INT;
    EmergencyStopFlag : BOOL;
    CleaningInProgress : BOOL;
END_VAR

BEGIN
    (* --- STATE 0: IDLE (WAITING FOR START) --- *)
    IF Current_State = 0 THEN
        (* Check for Start Button and ensure no Emergency Stop *)
        IF StartButton = TRUE AND EmergencyStop = FALSE THEN
            Current_State := 1; (* Transition to STATE 1: MOVING UP *)
        END_IF;
        
        (* Default outputs for IDLE state *)
        ElevatorUp := FALSE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
        
        (* Update flags *)
        CleaningInProgress := FALSE;
        EmergencyStopFlag := EmergencyStop;
        
    (* --- STATE 1: MOVING UP --- *)
    ELSIF Current_State = 1 THEN
        (* Logic: Move Up, Cleaning Off *)
        ElevatorUp := TRUE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
        
        (* Check transitions *)
        (* Transition to STATE 2 if Upper Limit reached and no E-Stop *)
        IF UpperLimit = TRUE AND EmergencyStop = FALSE THEN
            Current_State := 2; (* Transition to STATE 2: CLEANING AT UPPER LIMIT *)
        END_IF;
        
        (* Transition to STATE 0 if Emergency Stop *)
        IF EmergencyStop = TRUE THEN
            Current_State := 0; (* Transition to STATE 0: IDLE *)
        END_IF;
        
        (* Update flags *)
        CleaningInProgress := FALSE;
        EmergencyStopFlag := EmergencyStop;

    (* --- STATE 2: CLEANING AT UPPER LIMIT --- *)
    ELSIF Current_State = 2 THEN
        (* Logic: Descend, Clean Active *)
        ElevatorUp := FALSE;
        ElevatorDown := TRUE;
        RotateClockwise := TRUE;
        WaterPump := TRUE;
        
        (* Check transitions *)
        (* Transition to STATE 3 if Lower Limit reached and no E-Stop *)
        IF LowerLimit = TRUE AND EmergencyStop = FALSE THEN
            Current_State := 3; (* Transition to STATE 3: MOVING DOWN *)
        END_IF;
        
        (* Transition to STATE 0 if Emergency Stop *)
        IF EmergencyStop = TRUE THEN
            Current_State := 0; (* Transition to STATE 0: IDLE *)
        END_IF;
        
        (* Update flags *)
        CleaningInProgress := TRUE;
        EmergencyStopFlag := EmergencyStop;

    (* --- STATE 3: MOVING DOWN --- *)
    ELSIF Current_State = 3 THEN
        (* Logic: Move Down, Cleaning Off *)
        ElevatorUp := FALSE;
        ElevatorDown := TRUE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
        
        (* Check transitions *)
        (* Transition to STATE 4 if Lower Limit reached and no E-Stop *)
        IF LowerLimit = TRUE AND EmergencyStop = FALSE THEN
            Current_State := 4; (* Transition to STATE 4: CLEANING AT LOWER LIMIT *)
        END_IF;
        
        (* Transition to STATE 0 if Emergency Stop *)
        IF EmergencyStop = TRUE THEN
            Current_State := 0; (* Transition to STATE 0: IDLE *)
        END_IF;
        
        (* Update flags *)
        CleaningInProgress := FALSE;
        EmergencyStopFlag := EmergencyStop;

    (* --- STATE 4: CLEANING AT LOWER LIMIT --- *)
    ELSIF Current_State = 4 THEN
        (* Logic: Stop Moving, Clean Active *)
        ElevatorUp := FALSE;
        ElevatorDown := FALSE;
        RotateClockwise := TRUE;
        WaterPump := TRUE;
        
        (* Check transitions *)
        (* Transition to STATE 0 if Emergency Stop *)
        IF EmergencyStop = TRUE THEN
            Current_State := 0; (* Transition to STATE 0: IDLE *)
        END_IF;
        
        (* Note: System ceases operation here unless reset logic is external.
           If StartButton is pressed again while in STATE 4, it typically waits
           until the cycle completes or requires a manual reset. 
           Based on plan, we only transition on E-Stop. *)
        
        (* Update flags *)
        CleaningInProgress := TRUE;
        EmergencyStopFlag := EmergencyStop;

    (* --- STATE 5: EMERGENCY STOP (Handled via reset to STATE 0) --- *)
    ELSIF Current_State = 5 THEN
        (* This state is effectively bypassed by resetting to 0 immediately upon E-Stop *)
        ElevatorUp := FALSE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
        Current_State := 0;
        EmergencyStopFlag := TRUE;
    END_IF;
    
    (* Ensure EmergencyStopFlag is updated for safety logic if needed externally *)
    EmergencyStopFlag := EmergencyStop;

END_FUNCTION_BLOCK
END_ST