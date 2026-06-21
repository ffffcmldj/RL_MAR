FUNCTION_BLOCK ParcelSortingSystem
VAR_INPUT
    ParcelSizeSensor : REAL;
    DestinationCodeSensor : INT;
END_VAR
VAR_OUTPUT
    ConveyorBeltMotor : BOOL;
    SortingGate1 : BOOL;
    SortingGate2 : BOOL;
END_VAR
VAR
    SizeThreshold : REAL;
    ValidDestination : BOOL;
    ValidSize : BOOL;
    IsLargeParcel : BOOL;
    IsSmallParcel : BOOL;
    IsLocationA : BOOL;
    IsLocationB : BOOL;
END_VAR

SizeThreshold := 50.0;

ValidDestination := (DestinationCodeSensor = 1) OR (DestinationCodeSensor = 2);
ValidSize := (ParcelSizeSensor >= 0.0) AND (ParcelSizeSensor <= 200.0);

IsLargeParcel := (ParcelSizeSensor > SizeThreshold);
IsSmallParcel := (ParcelSizeSensor <= SizeThreshold);
IsLocationA := (DestinationCodeSensor = 1);
IsLocationB := (DestinationCodeSensor = 2);

IF (NOT ValidDestination) OR (NOT ValidSize) THEN
    ConveyorBeltMotor := FALSE;
    SortingGate1 := FALSE;
    SortingGate2 := FALSE;
ELSIF IsLargeParcel THEN
    ConveyorBeltMotor := TRUE;
    SortingGate1 := TRUE;
    SortingGate2 := FALSE;
ELSIF IsSmallParcel AND IsLocationA THEN
    ConveyorBeltMotor := TRUE;
    SortingGate1 := FALSE;
    SortingGate2 := TRUE;
ELSIF IsSmallParcel AND IsLocationB THEN
    ConveyorBeltMotor := TRUE;
    SortingGate1 := FALSE;
    SortingGate2 := FALSE;
ELSE
    ConveyorBeltMotor := FALSE;
    SortingGate1 := FALSE;
    SortingGate2 := FALSE;
END_IF

END_FUNCTION_BLOCK