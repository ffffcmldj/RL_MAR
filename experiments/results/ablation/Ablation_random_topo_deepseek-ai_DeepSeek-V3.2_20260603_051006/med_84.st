FUNCTION_BLOCK ParcelSortingSystem
VAR_INPUT
    ParcelSizeSensor : REAL;           (* Sensor input for parcel size in mm *)
    DestinationCodeSensor : INT;       (* Destination code: 1=Location A, 2=Location B *)
END_VAR
VAR_OUTPUT
    ConveyorBeltMotor : BOOL;          (* Output for conveyor belt motor: TRUE=On, FALSE=Off *)
    SortingGate1 : BOOL;               (* Output for sorting gate 1: TRUE=Open, FALSE=Closed *)
    SortingGate2 : BOOL;               (* Output for sorting gate 2: TRUE=Open, FALSE=Closed *)
END_VAR
VAR
    SizeThreshold : REAL := 100.0;     (* Threshold to distinguish large vs small parcels *)
    IsLargeParcel : BOOL;              (* Flag indicating parcel is large (>= threshold) *)
    IsSmallParcel : BOOL;              (* Flag indicating parcel is small (< threshold) *)
    IsValidDestination : BOOL;         (* Flag indicating destination code is valid *)
    IsValidSize : BOOL;                (* Flag indicating parcel size is valid *)
END_VAR

(* Initialize outputs to safe default states - all off/closed *)
ConveyorBeltMotor := FALSE;
SortingGate1 := FALSE;
SortingGate2 := FALSE;

(* Validate sensor inputs *)
IsValidSize := (ParcelSizeSensor > 0.0);                    (* Valid size must be positive *)
IsValidDestination := (DestinationCodeSensor = 1) OR (DestinationCodeSensor = 2);  (* Only codes 1 or 2 are valid *)

(* Determine parcel size category based on threshold *)
IsLargeParcel := (ParcelSizeSensor >= SizeThreshold) AND IsValidSize;
IsSmallParcel := (ParcelSizeSensor < SizeThreshold) AND (ParcelSizeSensor > 0.0) AND IsValidSize;

(* Main sorting logic - only execute if both inputs are valid *)
IF IsValidSize AND IsValidDestination THEN
    (* Valid parcel detected - activate conveyor belt *)
    ConveyorBeltMotor := TRUE;
    
    (* Route parcel based on size and destination *)
    IF IsLargeParcel THEN
        (* Large parcels always go to Sorting Gate 1 regardless of destination *)
        SortingGate1 := TRUE;      (* Open gate 1 *)
        SortingGate2 := FALSE;     (* Ensure gate 2 is closed *)
        
    ELSIF IsSmallParcel THEN
        (* Small parcels routing depends on destination code *)
        CASE DestinationCodeSensor OF
            1:  (* Destination A - route to Sorting Gate 2 *)
                SortingGate1 := FALSE;     (* Ensure gate 1 is closed *)
                SortingGate2 := TRUE;      (* Open gate 2 *)
                
            2:  (* Destination B - stay on conveyor, no gates activated *)
                SortingGate1 := FALSE;     (* Ensure gate 1 is closed *)
                SortingGate2 := FALSE;     (* Ensure gate 2 is closed *)
        END_CASE;
        
    ELSE
        (* Invalid size category - should not reach here due to validation *)
        (* Safety fallback: stop system and close all gates *)
        ConveyorBeltMotor := FALSE;
        SortingGate1 := FALSE;
        SortingGate2 := FALSE;
    END_IF;
    
ELSE
    (* Invalid input detected - stop system and close all gates *)
    ConveyorBeltMotor := FALSE;
    SortingGate1 := FALSE;
    SortingGate2 := FALSE;
END_IF;

END_FUNCTION_BLOCK