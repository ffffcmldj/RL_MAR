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
        LargeParcelThreshold : REAL := 10.0; (* Threshold for large parcels *)
    END_VAR

    // Initialization: Set default states
    ConveyorBeltMotor := FALSE;
    SortingGate1 := FALSE;
    SortingGate2 := FALSE;

    // Parcel Detection and Sorting Logic
    IF ParcelSizeSensor > 0.0 AND (DestinationCodeSensor = 1 OR DestinationCodeSensor = 2) THEN
        // Valid parcel detected
        ConveyorBeltMotor := TRUE; // Activate conveyor belt

        IF ParcelSizeSensor >= LargeParcelThreshold THEN
            // Large Parcel State
            SortingGate1 := TRUE; // Open sorting gate 1
            SortingGate2 := FALSE; // Ensure sorting gate 2 is closed
        ELSE
            // Small Parcel State
            IF DestinationCodeSensor = 1 THEN
                // Small Parcel to Location A State
                SortingGate1 := FALSE; // Ensure sorting gate 1 is closed
                SortingGate2 := TRUE; // Open sorting gate 2
            ELSIF DestinationCodeSensor = 2 THEN
                // Small Parcel to Location B State
                SortingGate1 := FALSE; // Ensure sorting gate 1 is closed
                SortingGate2 := FALSE; // Ensure sorting gate 2 is closed
            END_IF
        END_IF
    ELSE
        // Error State: Invalid inputs
        ConveyorBeltMotor := FALSE; // Stop conveyor belt
        SortingGate1 := FALSE; // Close sorting gate 1
        SortingGate2 := FALSE; // Close sorting gate 2
    END_IF
END_FUNCTION_BLOCK