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
    SpaceToRetrieve : INT := 0; (* Parking space number to retrieve *)
    RetrievalComplete : BOOL := FALSE; (* Internal flag for retrieval completion *)
END_VAR

METHOD MoveCarToExitGate : BOOL
VAR_INPUT
    SpaceNumber : INT;
END_VAR
BEGIN
    // Simulate car movement to exit gate
    // In a real system, this would control actuators, motors, etc.
    // For now, return TRUE to indicate successful movement
    MoveCarToExitGate := TRUE;
END_METHOD

// Main logic
IF NOT RetrievalInProgress THEN
    // Entry gate management
    IF EntryGateSensor THEN
        // Find first available parking space
        ParkingSpaceNumber := 0;
        FOR i := 1 TO 100 DO
            IF NOT ParkingSpaces[i] THEN
                ParkingSpaceNumber := i;
                ParkingSpaces[i] := TRUE;
                EXIT;
            END_IF;
        END_FOR;
    END_IF;
END_IF;

// Car retrieval management
IF CarDetected AND NOT RetrievalInProgress THEN
    RetrievalInProgress := TRUE;
    SpaceToRetrieve := ParkingSpaceNumber;
    RetrievalComplete := FALSE;
END_IF;

IF RetrievalInProgress THEN
    IF NOT RetrievalComplete THEN
        // Execute car movement to exit gate
        RetrievalComplete := MoveCarToExitGate(SpaceToRetrieve);
    ELSE
        // Wait for exit gate sensor to confirm car has left
        IF ExitGateSensor THEN
            // Mark parking space as available
            IF SpaceToRetrieve >= 1 AND SpaceToRetrieve <= 100 THEN
                ParkingSpaces[SpaceToRetrieve] := FALSE;
            END_IF;
            
            // Reset outputs
            ParkingSpaceNumber := 0;
            RetrievalInProgress := FALSE;
            SpaceToRetrieve := 0;
            RetrievalComplete := FALSE;
        END_IF;
    END_IF;
END_IF;

// Exit gate management (for normal exits without retrieval request)
IF ExitGateSensor AND NOT RetrievalInProgress AND ParkingSpaceNumber > 0 THEN
    // Mark current parking space as available
    IF ParkingSpaceNumber >= 1 AND ParkingSpaceNumber <= 100 THEN
        ParkingSpaces[ParkingSpaceNumber] := FALSE;
    END_IF;
    ParkingSpaceNumber := 0;
END_IF;

END_FUNCTION_BLOCK