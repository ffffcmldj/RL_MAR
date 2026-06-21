TYPE
    // No custom types required for this implementation
END_TYPE

FUNCTION_BLOCK Automated_Parking_Controller
VAR_INPUT
    EntryGateSensor : BOOL;     (* Sensor input for entry gate *)
    ExitGateSensor : BOOL;      (* Sensor input for exit gate *)
    CarDetected : BOOL;         (* Sensor input for car detection *)
END_VAR

VAR_OUTPUT
    ParkingSpaceNumber : INT := 0;          (* Allocated parking space number *)
    RetrievalInProgress : BOOL := FALSE;    (* Flag for car retrieval in progress *)
END_VAR

VAR
    ParkingSpaces : ARRAY[1..100] OF BOOL := [100(FALSE)];    (* Parking space status: TRUE=Occupied, FALSE=Available *)
    i : INT;                                                    (* Loop counter *)
    
    // Edge detection for sensor inputs
    EntryGateRisingEdge : R_TRIG;
    ExitGateRisingEdge : R_TRIG;
    CarDetectedRisingEdge : R_TRIG;
    
    // State management
    CurrentState : INT := 0;        (* 0=IDLE, 1=ALLOCATE_SPACE, 2=START_RETRIEVAL, 3=MOVE_CAR, 4=EXIT_GATE *)
    AllocatedSpace : INT := 0;      (* Temporary storage for allocated space number *)
    
    // Movement timer for retrieval simulation
    MoveCarTimer : TON;
    MoveCarComplete : BOOL := FALSE;
END_VAR

// Edge detection for sensor inputs
EntryGateRisingEdge(CLK := EntryGateSensor);
ExitGateRisingEdge(CLK := ExitGateSensor);
CarDetectedRisingEdge(CLK := CarDetected);

// Main state machine logic
CASE CurrentState OF
    0: (* IDLE State - Waiting for events *)
        IF EntryGateRisingEdge.Q AND (NOT RetrievalInProgress) THEN
            CurrentState := 1;    // Transition to ALLOCATE_SPACE
        ELSIF CarDetectedRisingEdge.Q AND (NOT RetrievalInProgress) THEN
            CurrentState := 2;    // Transition to START_RETRIEVAL
        ELSIF ExitGateRisingEdge.Q THEN
            CurrentState := 4;    // Transition to EXIT_GATE
        END_IF;
        
    1: (* ALLOCATE_SPACE State - Find and assign available parking space *)
        AllocatedSpace := 0;
        
        // Scan for first available parking space
        FOR i := 1 TO 100 DO
            IF (NOT ParkingSpaces[i]) AND (AllocatedSpace = 0) THEN
                AllocatedSpace := i;
            END_IF;
        END_FOR;
        
        // If space found, allocate it
        IF AllocatedSpace > 0 THEN
            ParkingSpaces[AllocatedSpace] := TRUE;
            ParkingSpaceNumber := AllocatedSpace;
        END_IF;
        
        CurrentState := 0;    // Return to IDLE
        
    2: (* START_RETRIEVAL State - Initiate car retrieval process *)
        RetrievalInProgress := TRUE;
        
        // Start movement timer (simulating car movement to exit)
        MoveCarTimer(IN := TRUE, PT := T#5S);
        MoveCarComplete := FALSE;
        
        CurrentState := 3;    // Transition to MOVE_CAR
        
    3: (* MOVE_CAR State - Execute car movement to exit gate *)
        MoveCarTimer(IN := TRUE, PT := T#5S);
        
        IF MoveCarTimer.Q THEN
            MoveCarComplete := TRUE;
        END_IF;
        
        // When movement is complete, free the parking space
        IF MoveCarComplete THEN
            IF (ParkingSpaceNumber >= 1) AND (ParkingSpaceNumber <= 100) THEN
                ParkingSpaces[ParkingSpaceNumber] := FALSE;
            END_IF;
            
            ParkingSpaceNumber := 0;
            RetrievalInProgress := FALSE;
            MoveCarComplete := FALSE;
            CurrentState := 0;    // Return to IDLE
        END_IF;
        
    4: (* EXIT_GATE State - Handle car exiting through exit gate *)
        // Free the parking space if it's currently allocated
        IF (ParkingSpaceNumber >= 1) AND (ParkingSpaceNumber <= 100) THEN
            ParkingSpaces[ParkingSpaceNumber] := FALSE;
        END_IF;
        
        ParkingSpaceNumber := 0;
        CurrentState := 0;    // Return to IDLE
        
END_CASE;

END_FUNCTION_BLOCK

FUNCTION MoveCarToExitGate : BOOL
VAR_INPUT
    SpaceNumber : INT;
END_VAR
VAR
    MovementTimer : TON;
END_VAR

// This function simulates the car movement process
// In a real system, this would interface with physical actuators
MovementTimer(IN := TRUE, PT := T#5S);

IF MovementTimer.Q THEN
    MoveCarToExitGate := TRUE;    // Movement completed
ELSE
    MoveCarToExitGate := FALSE;   // Movement in progress
END_IF;

END_FUNCTION