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
        bSizeValid : BOOL;
        bDestValid : BOOL;
        bIsLarge : BOOL;
        rSizeThreshold : REAL := 50.0;
    END_VAR

    (* Main logic body begins here *)
    
    (* Input validation *)
    bSizeValid := ParcelSizeSensor > 0.0;
    bDestValid := (DestinationCodeSensor = 1) OR (DestinationCodeSensor = 2);
    
    (* Size classification *)
    IF ParcelSizeSensor >= rSizeThreshold THEN
        bIsLarge := TRUE;
    ELSE
        bIsLarge := FALSE;
    END_IF;
    
    (* Main control logic *)
    IF bSizeValid AND bDestValid THEN
        ConveyorBeltMotor := TRUE;
        
        CASE DestinationCodeSensor OF
            1: (* Destination A *)
                IF bIsLarge THEN
                    SortingGate1 := TRUE;
                    SortingGate2 := FALSE;
                ELSE
                    SortingGate1 := FALSE;
                    SortingGate2 := TRUE;
                END_IF;
                
            2: (* Destination B *)
                IF bIsLarge THEN
                    SortingGate1 := TRUE;
                    SortingGate2 := FALSE;
                ELSE
                    SortingGate1 := FALSE;
                    SortingGate2 := FALSE;
                END_IF;
                
            ELSE
                SortingGate1 := FALSE;
                SortingGate2 := FALSE;
        END_CASE;
    ELSE
        (* Invalid input - stop conveyor and close all gates *)
        ConveyorBeltMotor := FALSE;
        SortingGate1 := FALSE;
        SortingGate2 := FALSE;
    END_IF;

END_FUNCTION_BLOCK;