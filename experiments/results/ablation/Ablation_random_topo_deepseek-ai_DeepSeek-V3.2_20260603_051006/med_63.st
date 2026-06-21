FUNCTION MoveCarToExitGate : BOOL
VAR_INPUT
    SpaceNumber : INT;
END_VAR
// Simulate car movement to exit gate
// In a real system, this would control physical actuators
MoveCarToExitGate := TRUE; // Return TRUE when movement is complete
END_FUNCTION

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
    ParkingSpaces : ARRAY[1..100] OF BOOL; (* Parking space status: TRUE=Occupied, FALSE=Available *)
    i : INT; (* Loop counter *)
    AssignedSpace : INT := 0; (* Temporary storage for assigned space *)
    RetrievalComplete : BOOL := FALSE; (* Flag to track retrieval completion *)
END_VAR

// Entry Gate Management
IF EntryGateSensor AND NOT RetrievalInProgress THEN
    // Find first available parking space
    AssignedSpace := 0;
    FOR i := 1 TO 100 DO
        IF NOT ParkingSpaces[i] THEN
            AssignedSpace := i;
            EXIT;
        END_IF
    END_FOR
    
    // If available space found, allocate it
    IF AssignedSpace > 0 THEN
        ParkingSpaces[AssignedSpace] := TRUE;
        ParkingSpaceNumber := AssignedSpace;
    END_IF
END_IF

// Exit Gate Management
IF ExitGateSensor AND (ParkingSpaceNumber > 0) THEN
    // Mark the space as available and reset output
    ParkingSpaces[ParkingSpaceNumber] := FALSE;
    ParkingSpaceNumber := 0;
END_IF

// Car Retrieval Management
IF CarDetected AND NOT RetrievalInProgress AND (ParkingSpaceNumber > 0) THEN
    RetrievalInProgress := TRUE;
    RetrievalComplete := FALSE;
END_IF

IF RetrievalInProgress AND NOT RetrievalComplete THEN
    // Execute car movement to exit gate
    RetrievalComplete := MoveCarToExitGate(ParkingSpaceNumber);
    
    IF RetrievalComplete THEN
        // Mark space as available and reset
        ParkingSpaces[ParkingSpaceNumber] := FALSE;
        ParkingSpaceNumber := 0;
        RetrievalInProgress := FALSE;
    END_IF
END_IF

END_FUNCTION_BLOCK