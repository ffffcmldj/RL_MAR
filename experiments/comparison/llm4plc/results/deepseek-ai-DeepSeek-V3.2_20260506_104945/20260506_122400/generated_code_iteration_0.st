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
    ParkingSpaces : ARRAY[1..100] OF BOOL; (* Parking space status: TRUE=Occupied, FALSE=Available *)
    state : INT := 0; (* Current state: 0=IDLE, 1=PROCESSING_ENTRY, 2=PROCESSING_EXIT, 3=PROCESSING_RETRIEVAL_REQUEST, 4=EXECUTING_RETRIEVAL *)
    prevState : INT := 0; (* Previous state for edge detection *)
    assignedSpace : INT := 0; (* Temporary storage for assigned parking space *)
    retrievalSpace : INT := 0; (* Temporary storage for space being retrieved *)
    entrySensorRising : BOOL; (* Edge detection for EntryGateSensor *)
    exitSensorRising : BOOL; (* Edge detection for ExitGateSensor *)
    carDetectedRising : BOOL; (* Edge detection for CarDetected *)
    moveCarResult : BOOL; (* Result from MoveCarToExitGate function *)
    i : INT; (* Loop counter *)
    prevEntryGateSensor : BOOL := FALSE; (* Previous value for rising edge detection *)
    prevExitGateSensor : BOOL := FALSE; (* Previous value for rising edge detection *)
    prevCarDetected : BOOL := FALSE; (* Previous value for rising edge detection *)
END_VAR

(* Rising edge detection for sensor inputs *)
entrySensorRising := EntryGateSensor AND NOT prevEntryGateSensor;
exitSensorRising := ExitGateSensor AND NOT prevExitGateSensor;
carDetectedRising := CarDetected AND NOT prevCarDetected;

prevEntryGateSensor := EntryGateSensor;
prevExitGateSensor := ExitGateSensor;
prevCarDetected := CarDetected;

(* State machine implementation *)
CASE state OF
    0: (* IDLE *)
        (* Maintain outputs as per plan *)
        ParkingSpaceNumber := 0;
        RetrievalInProgress := FALSE;
        
        (* State transitions *)
        IF entrySensorRising AND NOT RetrievalInProgress THEN
            state := 1; (* PROCESSING_ENTRY *)
        ELSIF carDetectedRising THEN
            state := 3; (* PROCESSING_RETRIEVAL_REQUEST *)
        END_IF;
        
    1: (* PROCESSING_ENTRY *)
        (* Scan for first available parking space *)
        assignedSpace := 0;
        FOR i := 1 TO 100 DO
            IF NOT ParkingSpaces[i] THEN
                assignedSpace := i;
                EXIT;
            END_IF;
        END_FOR;
        
        (* If space found, mark as occupied and output number *)
        IF assignedSpace > 0 THEN
            ParkingSpaces[assignedSpace] := TRUE;
            ParkingSpaceNumber := assignedSpace;
        ELSE
            (* No space available - keep ParkingSpaceNumber at 0 *)
            ParkingSpaceNumber := 0;
        END_IF;
        
        (* Transition back to IDLE *)
        state := 0;
        
    2: (* PROCESSING_EXIT *)
        (* Mark the space as available *)
        IF ParkingSpaceNumber >= 1 AND ParkingSpaceNumber <= 100 THEN
            ParkingSpaces[ParkingSpaceNumber] := FALSE;
        END_IF;
        
        (* Reset output *)
        ParkingSpaceNumber := 0;
        
        (* Transition back to IDLE *)
        state := 0;
        
    3: (* PROCESSING_RETRIEVAL_REQUEST *)
        (* Set retrieval flag *)
        RetrievalInProgress := TRUE;
        
        (* Determine which space to retrieve - simplified logic: retrieve first occupied space *)
        (* Note: This is a simplification - actual implementation would need specific retrieval logic *)
        retrievalSpace := 0;
        FOR i := 1 TO 100 DO
            IF ParkingSpaces[i] THEN
                retrievalSpace := i;
                EXIT;
            END_IF;
        END_FOR;
        
        (* If a space was found, transition to executing retrieval *)
        IF retrievalSpace > 0 THEN
            ParkingSpaceNumber := retrievalSpace;
            state := 4; (* EXECUTING_RETRIEVAL *)
        ELSE
            (* No cars to retrieve - go back to IDLE *)
            RetrievalInProgress := FALSE;
            state := 0;
        END_IF;
        
    4: (* EXECUTING_RETRIEVAL *)
        (* Call helper function to move car *)
        moveCarResult := MoveCarToExitGate(retrievalSpace);
        
        (* When movement complete, transition to PROCESSING_EXIT *)
        IF moveCarResult THEN
            state := 2; (* PROCESSING_EXIT *)
        END_IF;
        
END_CASE;

(* Handle exit gate sensor independently for cars leaving without retrieval request *)
IF exitSensorRising AND NOT RetrievalInProgress AND ParkingSpaceNumber > 0 THEN
    (* Direct exit without retrieval request *)
    ParkingSpaces[ParkingSpaceNumber] := FALSE;
    ParkingSpaceNumber := 0;
END_IF;

END_FUNCTION_BLOCK

FUNCTION MoveCarToExitGate : BOOL
VAR_INPUT
    SpaceNumber : INT;
END_VAR
VAR
    (* This function would contain the actual car movement logic *)
    (* For now, return TRUE immediately to simulate successful movement *)
    (* In a real implementation, this would coordinate with physical actuators and sensors *)
END_VAR

    (* Simplified implementation - always return TRUE after one scan *)
    MoveCarToExitGate := TRUE;
    
END_FUNCTION
END_ST