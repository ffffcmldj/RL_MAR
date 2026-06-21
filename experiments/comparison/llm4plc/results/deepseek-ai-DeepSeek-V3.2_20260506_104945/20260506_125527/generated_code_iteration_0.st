START_ST
FUNCTION_BLOCK ParcelSortingSystem
VAR_INPUT
    ParcelSizeSensor : REAL; (* Sensor input for parcel size in millimeters *)
    DestinationCodeSensor : INT; (* Destination code: 1 = Location A, 2 = Location B *)
END_VAR
VAR_OUTPUT
    ConveyorBeltMotor : BOOL; (* Output for conveyor belt motor: TRUE = On, FALSE = Off *)
    SortingGate1 : BOOL; (* Output for sorting gate 1: TRUE = Open, FALSE = Closed *)
    SortingGate2 : BOOL; (* Output for sorting gate 2: TRUE = Open, FALSE = Closed *)
END_VAR
VAR
    state : INT; (* Current state of the Finite State Machine (0-6) *)
    prevState : INT; (* Previous state, used for debugging or monitoring *)
    sizeThreshold : REAL := 100.0; (* Threshold to distinguish large vs small parcels. Large >= 100.0 mm *)
    parcelDetected : BOOL; (* TRUE when a parcel is detected based on sensor readings *)
    parcelSizeValid : BOOL; (* TRUE if ParcelSizeSensor > 0.0 *)
    destinationCodeValid : BOOL; (* TRUE if DestinationCodeSensor is 1 or 2 *)
    isLargeParcel : BOOL; (* TRUE if ParcelSizeSensor >= sizeThreshold AND parcelSizeValid *)
    isSmallParcel : BOOL; (* TRUE if ParcelSizeSensor < sizeThreshold AND parcelSizeValid *)
END_VAR

(* State Definitions:
   0: INITIALIZATION
   1: WAITING_FOR_PARCEL
   2: VALIDATION_CHECK
   3: PROCESS_LARGE_PARCEL
   4: PROCESS_SMALL_A
   5: PROCESS_SMALL_B
   6: ERROR_HANDLING
*)

(* Initialize the system on the first scan *)
IF state = 0 THEN
    ConveyorBeltMotor := FALSE;
    SortingGate1 := FALSE;
    SortingGate2 := FALSE;
    prevState := 0;
    state := 1; (* Transition to waiting state after initialization *)
END_IF;

(* Calculate derived signals for parcel detection and validation *)
parcelSizeValid := (ParcelSizeSensor > 0.0);
destinationCodeValid := (DestinationCodeSensor = 1) OR (DestinationCodeSensor = 2);
parcelDetected := parcelSizeValid AND (DestinationCodeSensor > 0);
isLargeParcel := parcelSizeValid AND (ParcelSizeSensor >= sizeThreshold);
isSmallParcel := parcelSizeValid AND (ParcelSizeSensor < sizeThreshold);

(* Finite State Machine Logic *)
CASE state OF
    1: (* WAITING_FOR_PARCEL *)
        ConveyorBeltMotor := FALSE;
        SortingGate1 := FALSE;
        SortingGate2 := FALSE;
        
        IF parcelDetected THEN
            prevState := state;
            state := 2; (* Transition to validation check *)
        END_IF;
        
    2: (* VALIDATION_CHECK *)
        ConveyorBeltMotor := FALSE;
        SortingGate1 := FALSE;
        SortingGate2 := FALSE;
        
        IF NOT parcelSizeValid OR NOT destinationCodeValid THEN
            prevState := state;
            state := 6; (* Invalid input, go to error handling *)
        ELSIF isLargeParcel THEN
            prevState := state;
            state := 3; (* Process large parcel *)
        ELSIF isSmallParcel AND (DestinationCodeSensor = 1) THEN
            prevState := state;
            state := 4; (* Process small parcel for Location A *)
        ELSIF isSmallParcel AND (DestinationCodeSensor = 2) THEN
            prevState := state;
            state := 5; (* Process small parcel for Location B *)
        END_IF;
        
    3: (* PROCESS_LARGE_PARCEL *)
        ConveyorBeltMotor := TRUE;
        SortingGate1 := TRUE;
        SortingGate2 := FALSE;
        
        IF NOT parcelDetected THEN
            prevState := state;
            state := 1; (* Parcel cleared, return to waiting *)
        END_IF;
        
    4: (* PROCESS_SMALL_A *)
        ConveyorBeltMotor := TRUE;
        SortingGate1 := FALSE;
        SortingGate2 := TRUE;
        
        IF NOT parcelDetected THEN
            prevState := state;
            state := 1; (* Parcel cleared, return to waiting *)
        END_IF;
        
    5: (* PROCESS_SMALL_B *)
        ConveyorBeltMotor := TRUE;
        SortingGate1 := FALSE;
        SortingGate2 := FALSE;
        
        IF NOT parcelDetected THEN
            prevState := state;
            state := 1; (* Parcel cleared, return to waiting *)
        END_IF;
        
    6: (* ERROR_HANDLING *)
        ConveyorBeltMotor := FALSE;
        SortingGate1 := FALSE;
        SortingGate2 := FALSE;
        
        IF parcelSizeValid AND destinationCodeValid THEN
            prevState := state;
            state := 1; (* Inputs became valid, return to waiting *)
        END_IF;
        
END_CASE;

END_FUNCTION_BLOCK
END_ST