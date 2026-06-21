ructured-text
FUNCTION_BLOCK ParcelSortingSystem
VAR_INPUT
    ParcelSizeSensor : REAL; (* Sensor input for parcel size *)
    DestinationCodeSensor : INT; (* Destination code: 1=A, 2=B *)
END_VAR
VAR_OUTPUT
    ConveyorBeltMotor : BOOL; (* Output for conveyor belt motor: TRUE=On, FALSE=Off *)
    SortingGate1 : BOOL; (* Output for sorting gate 1: TRUE=Open, FALSE=Closed *)
    SortingGate2 : BOOL; (* Output for sorting gate 2: TRUE=Open, FALSE=Closed *)
END_VAR
VAR
    state : INT; (* The state variable *)
    prevState : INT; (* The previous state variable *)
    threshold_large : REAL := 50.0; (* Threshold for large parcels *)
    max_size : REAL := 100.0; (* Max size of parcel *)
END_VAR

(* State definitions *)
STATE 0: INITIALIZE
    ConveyorBeltMotor := FALSE;
    SortingGate1 := FALSE;
    SortingGate2 := FALSE;

STATE 1: PROCESS PARCEL
    ConveyorBeltMotor := TRUE;
    SortingGate1 := FALSE;
    SortingGate2 := FALSE;

STATE 2: ROUTE LARGE PARCEL TO GATE 1
    ConveyorBeltMotor := TRUE;
    SortingGate1 := TRUE;
    SortingGate2 := FALSE;

STATE 3: ROUTE SMALL PARCEL TO GATE 2
    ConveyorBeltMotor := TRUE;
    SortingGate1 := FALSE;
    SortingGate2 := TRUE;

STATE 4: ALLOW SMALL PARCEL TO CONTINUE ON CONVEYOR
    ConveyorBeltMotor := TRUE;
    SortingGate1 := FALSE;
    SortingGate2 := FALSE;

STATE 5: INVALID PARCEL DETECTED
    ConveyorBeltMotor := FALSE;
    SortingGate1 := FALSE;
    SortingGate2 := FALSE;

(* State transitions *)
IF state = 0 THEN
    state := 1; (* Always transition to PROCESS PARCEL on initialization *)
ELSIF state = 1 THEN
    IF ParcelSizeSensor >= threshold_large AND DestinationCodeSensor = 1 THEN
        state := 2; (* Route large parcel to gate 1 *)
    ELSIF ParcelSizeSensor < threshold_large AND DestinationCodeSensor = 1 THEN
        state := 3; (* Route small parcel to gate 2 *)
    ELSIF ParcelSizeSensor < threshold_large AND DestinationCodeSensor = 2 THEN
        state := 4; (* Allow small parcel to continue on conveyor *)
    ELSIF ParcelSizeSensor < 0 OR ParcelSizeSensor > max_size OR (DestinationCodeSensor <> 1 AND DestinationCodeSensor <> 2) THEN
        state := 5; (* Invalid parcel detected *)
    END_IF
ELSIF state = 2 THEN
    state := 0; (* Reset for next parcel after routing to gate 1 *)
ELSIF state = 3 THEN
    state := 0; (* Reset for next parcel after routing to gate 2 *)
ELSIF state = 4 THEN
    state := 0; (* Reset for next parcel after allowing small parcel to continue *)
ELSIF state = 5 THEN
    state := 0; (* Reset for next parcel after handling invalid parcel *)
END_IF

END_FUNCTION_BLOCK