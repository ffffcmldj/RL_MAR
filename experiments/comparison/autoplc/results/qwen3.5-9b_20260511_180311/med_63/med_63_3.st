FUNCTION MoveCarToExitGate : BOOL
VAR_INPUT
    SpaceNumber : INT;
END_VAR
VAR
    k : INT;
    LoopCount : INT;
END_VAR
MoveCarToExitGate := TRUE;
END_FUNCTION

FUNCTION_BLOCK Automated_Parking_Controller
VAR_INPUT
    EntryGateSensor : BOOL;
    ExitGateSensor : BOOL;
    CarDetected : BOOL;
END_VAR
VAR_OUTPUT
    ParkingSpaceNumber : INT := 0;
    RetrievalInProgress : BOOL := FALSE;
END_VAR
VAR
    ParkingSpaces : ARRAY[1..100] OF BOOL;
    i : INT;
    j : INT;
    SpaceFound : BOOL;
    MoveResult : BOOL;
END_VAR


    IF EntryGateSensor THEN
        IF RetrievalInProgress = FALSE THEN
            SpaceFound := FALSE;
            FOR i := 1 TO 100 DO
                IF ParkingSpaces[i] = FALSE THEN
                    SpaceFound := TRUE;
                    ParkingSpaces[i] := TRUE;
                    ParkingSpaceNumber := i;
                    EXIT;
                END_IF;
            END_FOR;
        END_IF;
    END_IF;

    IF CarDetected THEN
        IF RetrievalInProgress = FALSE THEN
            RetrievalInProgress := TRUE;
            MoveResult := MoveCarToExitGate(ParkingSpaceNumber);
            IF MoveResult = TRUE THEN
                ParkingSpaces[ParkingSpaceNumber] := FALSE;
                ParkingSpaceNumber := 0;
                RetrievalInProgress := FALSE;
            END_IF;
        END_IF;
    END_IF;

    IF ExitGateSensor THEN
        IF ParkingSpaceNumber > 0 THEN
            ParkingSpaces[ParkingSpaceNumber] := FALSE;
            ParkingSpaceNumber := 0;
            RetrievalInProgress := FALSE;
        END_IF;
    END_IF;

    FOR j := 1 TO 100 DO
        ParkingSpaces[j] := FALSE;
    END_FOR;
END_FUNCTION_BLOCK