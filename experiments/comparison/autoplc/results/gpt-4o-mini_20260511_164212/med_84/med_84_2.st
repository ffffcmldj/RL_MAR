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
        ParcelSizeThreshold : REAL := 10.0; (* Threshold for determining large parcels *)
        State : INT := 0; (* 0=Idle, 1=Processing, 2=Error *)
    END_VAR

    (* Initialization *)
    ConveyorBeltMotor := FALSE;
    SortingGate1 := FALSE;
    SortingGate2 := FALSE;

    CASE State OF
        0: (* Idle State *)
            IF (ParcelSizeSensor > 0) AND ((DestinationCodeSensor = 1) OR (DestinationCodeSensor = 2)) THEN
                State := 1; (* Transition to Processing State *)
            END_IF;

        1: (* Processing State *)
            ConveyorBeltMotor := TRUE; (* Activate conveyor belt motor *)
            IF ParcelSizeSensor > ParcelSizeThreshold THEN
                SortingGate1 := TRUE; (* Open Sorting Gate 1 for large parcels *)
                SortingGate2 := FALSE; (* Ensure Sorting Gate 2 is closed *)
            ELSIF ParcelSizeSensor <= ParcelSizeThreshold THEN
                IF DestinationCodeSensor = 1 THEN
                    SortingGate1 := FALSE; (* Ensure Sorting Gate 1 is closed *)
                    SortingGate2 := TRUE; (* Open Sorting Gate 2 for location A *)
                ELSIF DestinationCodeSensor = 2 THEN
                    SortingGate1 := FALSE; (* Ensure Sorting Gate 1 is closed *)
                    SortingGate2 := FALSE; (* Keep Sorting Gate 2 closed for location B *)
                ELSE
                    State := 2; (* Transition to Error State *)
                END_IF;
            END_IF;

            (* After processing, reset to Idle state *)
            State := 0;

        2: (* Error State *)
            ConveyorBeltMotor := FALSE; (* Stop conveyor belt motor *)
            SortingGate1 := FALSE; (* Close Sorting Gate 1 *)
            SortingGate2 := FALSE; (* Close Sorting Gate 2 *)

            (* Wait for valid inputs to return to Idle state *)
            IF (ParcelSizeSensor > 0) AND ((DestinationCodeSensor = 1) OR (DestinationCodeSensor = 2)) THEN
                State := 1; (* Transition back to Processing State *)
            END_IF;
    END_CASE;
END_FUNCTION_BLOCK