FUNCTION_BLOCK ParcelSortingSystem
VAR_INPUT
    ParcelSizeSensor : REAL;     (* Sensor input for parcel size in millimeters *)
    DestinationCodeSensor : INT; (* Destination code: 1=Location A, 2=Location B *)
END_VAR

VAR_OUTPUT
    ConveyorBeltMotor : BOOL;    (* Output for conveyor belt motor: TRUE=On, FALSE=Off *)
    SortingGate1 : BOOL;         (* Output for sorting gate 1: TRUE=Open, FALSE=Closed *)
    SortingGate2 : BOOL;         (* Output for sorting gate 2: TRUE=Open, FALSE=Closed *)
END_VAR

VAR
    bSizeValid : BOOL;           (* Flag indicating valid parcel size *)
    bDestValid : BOOL;           (* Flag indicating valid destination code *)
    bIsLargeParcel : BOOL;       (* Flag indicating large parcel *)
    bIsSmallParcel : BOOL;       (* Flag indicating small parcel *)
    bDestLocationA : BOOL;       (* Flag for destination Location A *)
    bDestLocationB : BOOL;       (* Flag for destination Location B *)
    
    (* Constants for size thresholds *)
    LARGE_SIZE_THRESHOLD : REAL := 500.0;  (* Parcels >= 500mm are considered large *)
    MIN_VALID_SIZE : REAL := 50.0;         (* Minimum valid parcel size *)
    MAX_VALID_SIZE : REAL := 1000.0;       (* Maximum valid parcel size *)
END_VAR

(* Main program logic *)
METHOD ProcessParcelSorting
    (* Initialize all outputs to safe state *)
    ConveyorBeltMotor := FALSE;
    SortingGate1 := FALSE;
    SortingGate2 := FALSE;
    
    (* Validate parcel size *)
    bSizeValid := (ParcelSizeSensor >= MIN_VALID_SIZE) AND 
                  (ParcelSizeSensor <= MAX_VALID_SIZE);
    
    (* Validate destination code *)
    bDestValid := (DestinationCodeSensor = 1) OR (DestinationCodeSensor = 2);
    
    (* Determine parcel size category *)
    bIsLargeParcel := ParcelSizeSensor >= LARGE_SIZE_THRESHOLD;
    bIsSmallParcel := (ParcelSizeSensor < LARGE_SIZE_THRESHOLD) AND bSizeValid;
    
    (* Determine destination *)
    bDestLocationA := (DestinationCodeSensor = 1) AND bDestValid;
    bDestLocationB := (DestinationCodeSensor = 2) AND bDestValid;
    
    (* Main sorting logic *)
    IF bSizeValid AND bDestValid THEN
        (* Valid parcel detected - start conveyor *)
        ConveyorBeltMotor := TRUE;
        
        IF bIsLargeParcel THEN
            (* Large parcels always go to sorting gate 1 *)
            SortingGate1 := TRUE;
            SortingGate2 := FALSE;
            
        ELSIF bIsSmallParcel THEN
            (* Small parcels routing based on destination *)
            IF bDestLocationA THEN
                (* Small parcels for Location A go to sorting gate 2 *)
                SortingGate1 := FALSE;
                SortingGate2 := TRUE;
            ELSIF bDestLocationB THEN
                (* Small parcels for Location B stay on conveyor *)
                SortingGate1 := FALSE;
                SortingGate2 := FALSE;
            END_IF;
        END_IF;
        
    ELSE
        (* Invalid input detected - stop system and close all gates *)
        ConveyorBeltMotor := FALSE;
        SortingGate1 := FALSE;
        SortingGate2 := FALSE;
    END_IF;
END_METHOD
END_FUNCTION_BLOCK