FUNCTION_BLOCK ParcelSortingSystem
VAR_INPUT
    ParcelSizeSensor : REAL;           (* Sensor input for parcel size in centimeters *)
    DestinationCodeSensor : INT;       (* Destination code: 1=Location A, 2=Location B *)
END_VAR

VAR_OUTPUT
    ConveyorBeltMotor : BOOL;          (* Output for conveyor belt motor: TRUE=On, FALSE=Off *)
    SortingGate1 : BOOL;               (* Output for sorting gate 1: TRUE=Open, FALSE=Closed *)
    SortingGate2 : BOOL;               (* Output for sorting gate 2: TRUE=Open, FALSE=Closed *)
END_VAR

VAR
    SizeThreshold : REAL := 50.0;      (* Threshold to distinguish large vs small parcels *)
    MinValidSize : REAL := 5.0;        (* Minimum valid parcel size to prevent false positives *)
    MaxValidSize : REAL := 200.0;      (* Maximum valid parcel size for system capacity *)
    ValidSizeDetected : BOOL;          (* Flag indicating if parcel size is within valid range *)
    ValidDestinationDetected : BOOL;   (* Flag indicating if destination code is valid *)
END_VAR

(* Main execution logic - runs on every PLC scan cycle *)

(* Validate sensor inputs *)
ValidSizeDetected := (ParcelSizeSensor >= MinValidSize) AND (ParcelSizeSensor <= MaxValidSize);
ValidDestinationDetected := (DestinationCodeSensor = 1) OR (DestinationCodeSensor = 2);

(* Control logic based on validated inputs *)
IF ValidSizeDetected AND ValidDestinationDetected THEN
    (* Valid parcel detected - activate conveyor belt *)
    ConveyorBeltMotor := TRUE;
    
    (* Sorting decision logic *)
    IF ParcelSizeSensor >= SizeThreshold THEN
        (* Large parcel: route to sorting gate 1 regardless of destination *)
        SortingGate1 := TRUE;
        SortingGate2 := FALSE;
    ELSIF DestinationCodeSensor = 1 THEN
        (* Small parcel destined for Location A: route to sorting gate 2 *)
        SortingGate1 := FALSE;
        SortingGate2 := TRUE;
    ELSE
        (* Small parcel destined for Location B: keep on main conveyor *)
        SortingGate1 := FALSE;
        SortingGate2 := FALSE;
    END_IF;
ELSE
    (* Invalid parcel detected: stop conveyor and close all gates for safety *)
    ConveyorBeltMotor := FALSE;
    SortingGate1 := FALSE;
    SortingGate2 := FALSE;
END_IF;

END_FUNCTION_BLOCK