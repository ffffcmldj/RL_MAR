FUNCTION_BLOCK ParcelSortingSystem
VAR_INPUT
    ParcelSizeSensor : REAL; (* Sensor input for parcel size in centimeters *)
    DestinationCodeSensor : INT; (* Destination code: 1=Location A, 2=Location B *)
END_VAR
VAR_OUTPUT
    ConveyorBeltMotor : BOOL; (* Output for conveyor belt motor: TRUE=On, FALSE=Off *)
    SortingGate1 : BOOL; (* Output for sorting gate 1: TRUE=Open, FALSE=Closed *)
    SortingGate2 : BOOL; (* Output for sorting gate 2: TRUE=Open, FALSE=Closed *)
END_VAR
VAR
    LargeSizeThreshold : REAL := 50.0; (* Threshold to classify parcels as large (>=50cm) or small (<50cm) *)
    IsParcelSizeValid : BOOL; (* Flag to indicate if parcel size is valid *)
    IsDestinationCodeValid : BOOL; (* Flag to indicate if destination code is valid *)
    IsLargeParcel : BOOL; (* Flag to indicate if parcel is classified as large *)
    IsSmallParcel : BOOL; (* Flag to indicate if parcel is classified as small *)
END_VAR

(* Main control logic for parcel sorting system *)
(* This function block executes on every PLC scan cycle *)

(* Step 1: Input validation *)
(* Validate parcel size - must be positive value *)
IsParcelSizeValid := ParcelSizeSensor > 0.0;

(* Validate destination code - must be 1 or 2 *)
IsDestinationCodeValid := (DestinationCodeSensor = 1) OR (DestinationCodeSensor = 2);

(* Step 2: Check if all inputs are valid *)
IF IsParcelSizeValid AND IsDestinationCodeValid THEN
    (* Step 3: Classify parcel size *)
    (* Compare parcel size against threshold to determine if large or small *)
    IF ParcelSizeSensor >= LargeSizeThreshold THEN
        IsLargeParcel := TRUE;
        IsSmallParcel := FALSE;
    ELSE
        IsLargeParcel := FALSE;
        IsSmallParcel := TRUE;
    END_IF;
    
    (* Step 4: Execute sorting logic based on parcel classification and destination *)
    (* Turn on conveyor belt for all valid parcels *)
    ConveyorBeltMotor := TRUE;
    
    (* Large parcel handling - route to sorting gate 1 regardless of destination *)
    IF IsLargeParcel THEN
        SortingGate1 := TRUE;    (* Open gate 1 for large parcels *)
        SortingGate2 := FALSE;   (* Keep gate 2 closed *)
    
    (* Small parcel handling - route based on destination *)
    ELSIF IsSmallParcel THEN
        (* Check destination code for small parcels *)
        IF DestinationCodeSensor = 1 THEN
            (* Small parcel for Location A - route to sorting gate 2 *)
            SortingGate1 := FALSE;   (* Keep gate 1 closed *)
            SortingGate2 := TRUE;    (* Open gate 2 *)
        ELSIF DestinationCodeSensor = 2 THEN
            (* Small parcel for Location B - stay on conveyor belt *)
            SortingGate1 := FALSE;   (* Keep gate 1 closed *)
            SortingGate2 := FALSE;   (* Keep gate 2 closed *)
        END_IF;
    END_IF;
    
ELSE
    (* Step 5: Error handling for invalid inputs *)
    (* Stop conveyor belt and close all gates when inputs are invalid *)
    ConveyorBeltMotor := FALSE;   (* Stop the conveyor belt *)
    SortingGate1 := FALSE;        (* Close sorting gate 1 *)
    SortingGate2 := FALSE;        (* Close sorting gate 2 *)
    
    (* Reset classification flags *)
    IsLargeParcel := FALSE;
    IsSmallParcel := FALSE;
END_IF;

END_FUNCTION_BLOCK