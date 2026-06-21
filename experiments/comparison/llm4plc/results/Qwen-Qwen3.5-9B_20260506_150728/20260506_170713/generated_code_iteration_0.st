START_ST
FUNCTION_BLOCK Automated_Parking_Controller
VAR_INPUT
    EntryGateSensor : BOOL; (* Sensor input for entry gate *)
    ExitGateSensor : BOOL; (* Sensor input for exit gate *)
    CarDetected : BOOL; (* Sensor input for car detection *)
END_VAR
VAR_OUTPUT
    ParkingSpaceNumber : INT := 0; (* Allocated parking space number *)
    RetrievalInProgress : BOOL := FALSE; (* Flag for car retrieval in progress *)
END_VAR
VAR
    (* State Machine Definition *)
    CurrentState : INT := 0; (* 0:IDLE, 1:ENTRY_SCAN, 2:ENTRY_COMMIT, 3:RETRIEVAL_MOVE, 4:RETRIEVAL_COMPLETE *)
    
    (* Local Variables for Logic *)
    AllocatedSpaceIndex : INT; (* Temporary storage for found space index *)
    EntryGateClear : BOOL := FALSE; (* Required variable to detect car leaving entry gate - Assumed input for plan completion *)
    MoveCarResult : BOOL; (* Result from MoveCarToExitGate *)
    
    (* Parking Space Array *)
    ParkingSpaces : ARRAY[1..100] OF BOOL; (* TRUE=Occupied, FALSE=Available *)
    i : INT; (* Loop counter *)
END_VAR

BEGIN
    (* --------------------------------------------------------- *)
    (* STATE 0: IDLE *)
    (* Waiting for an event. No actuators active. *)
    (* Check for Entry Request *)
    IF EntryGateSensor AND (NOT RetrievalInProgress) THEN
        CurrentState := 1; (* Transition to ENTRY_SCAN *)
    END_IF;
    
    (* Check for Retrieval Request *)
    IF CarDetected AND (NOT RetrievalInProgress) THEN
        CurrentState := 3; (* Transition to RETRIEVAL_MOVE *)
    END_IF;
    
    (* --------------------------------------------------------- *)
    (* STATE 1: ENTRY_SCAN *)
    (* Scanning ParkingSpaces array for the first available slot *)
    IF CurrentState = 1 THEN
        AllocatedSpaceIndex := 0; (* Reset index *)
        FOR i := 1 TO 100 DO
            IF NOT ParkingSpaces[i] THEN
                AllocatedSpaceIndex := i;
                (* Mark space as occupied immediately upon finding it *)
                ParkingSpaces[i] := TRUE;
                (* Transition to COMMIT state to output number and wait for entry clear *)
                CurrentState := 2;
                EXIT;
            END_IF;
        END_FOR;
        
        (* If loop completes without finding a space, stay in State 1 or return to Idle *)
        (* Per plan: If full, do nothing. We stay in State 1 until a space opens or reset. *)
        (* However, to prevent infinite loop if full, we can check if we are stuck. *)
        (* For this implementation, we assume a space will eventually open or the system resets. *)
        (* If no space found, we remain in State 1 waiting for a space to free up (via retrieval). *)
    END_IF;
    
    (* --------------------------------------------------------- *)
    (* STATE 2: ENTRY_COMMIT *)
    (* Space found. Output number. Wait for car to pass entry gate. *)
    IF CurrentState = 2 THEN
        ParkingSpaceNumber := AllocatedSpaceIndex;
        (* Wait for EntryGateClear signal to indicate car has entered and gate can close *)
        IF EntryGateClear THEN
            (* Car has entered. Reset outputs and return to IDLE *)
            ParkingSpaceNumber := 0;
            CurrentState := 0;
        END_IF;
    END_IF;
    
    (* --------------------------------------------------------- *)
    (* STATE 3: RETRIEVAL_MOVE *)
    (* Retrieval requested. Move car to exit. *)
    IF CurrentState = 3 THEN
        RetrievalInProgress := TRUE;
        (* Call helper function to move car *)
        MoveCarResult := MoveCarToExitGate(AllocatedSpaceIndex);
        
        IF MoveCarResult THEN
            (* Movement successful. Transition to COMPLETE *)
            CurrentState := 4;
        END_IF;
    END_IF;
    
    (* --------------------------------------------------------- *)
    (* STATE 4: RETRIEVAL_COMPLETE *)
    (* Move completed. Free space and reset outputs. *)
    IF CurrentState = 4 THEN
        (* Mark space as available *)
        IF AllocatedSpaceIndex > 0 THEN
            ParkingSpaces[AllocatedSpaceIndex] := FALSE;
        END_IF;
        
        (* Reset outputs *)
        ParkingSpaceNumber := 0;
        RetrievalInProgress := FALSE;
        
        (* Return to IDLE *)
        CurrentState := 0;
    END_IF;
    
    (* Default: If state is invalid or 0, ensure outputs are safe *)
    IF CurrentState = 0 THEN
        IF RetrievalInProgress THEN
            RetrievalInProgress := FALSE;
        END_IF;
    END_IF;
END_FUNCTION_BLOCK

FUNCTION MoveCarToExitGate : BOOL
VAR_INPUT
    SpaceNumber : INT;
END_VAR
VAR_OUTPUT
    (* No specific output required by plan, logic is internal *)
END_VAR
VAR
    (* Local simulation variables *)
    SimulatedSuccess : BOOL := TRUE;
END_VAR

BEGIN
    (* Logic to simulate moving a car from SpaceNumber to Exit Gate *)
    (* In a real system, this would control conveyors, lifts, or gates *)
    
    (* Validation check *)
    IF SpaceNumber >= 1 AND SpaceNumber <= 100 THEN
        SimulatedSuccess := TRUE;
        (* Simulate movement time or logic here *)
        (* For example: MoveCarToExitGate(SpaceNumber); *)
    ELSE
        SimulatedSuccess := FALSE;
    END_IF;
    
    MoveCarToExitGate := SimulatedSuccess;
END_FUNCTION
END_ST