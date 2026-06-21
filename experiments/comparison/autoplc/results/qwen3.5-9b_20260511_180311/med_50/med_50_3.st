FUNCTION_BLOCK CarParkingSystem
VAR_INPUT
    NewCarSlot : INT;
END_VAR
VAR_OUTPUT
    Elevator1Busy : BOOL;
    Elevator2Busy : BOOL;
    Elevator1Position : INT;
    Elevator2Position : INT;
END_VAR
VAR
    Elevator1Target : INT := 0;
    Elevator2Target : INT := 0;
    CarSlots : ARRAY[1..100] OF BOOL;
    CurrentSlot : INT := 0;
    SlotFound : BOOL;
    IsElevator1Busy : BOOL;
    IsElevator2Busy : BOOL;
    IsSlotOccupied : BOOL;
    IsNewTaskAssigned : BOOL;
    IsElevator1AtTarget : BOOL;
    IsElevator2AtTarget : BOOL;
END_VAR


    IsNewTaskAssigned := FALSE;
    IsElevator1Busy := FALSE;
    IsElevator2Busy := FALSE;
    IsSlotOccupied := FALSE;
    SlotFound := FALSE;

    IF NewCarSlot >= 1 AND NewCarSlot <= 100 THEN
        FOR CurrentSlot FROM 1 TO 100 DO
            IF CarSlots[CurrentSlot] = TRUE THEN
                IsSlotOccupied := TRUE;
                EXIT;
            END_IF;
        END_FOR;

        IF IsSlotOccupied = FALSE THEN
            IF NewCarSlot >= 1 AND NewCarSlot <= 50 THEN
                Elevator1Target := NewCarSlot;
                Elevator1Busy := TRUE;
                IsNewTaskAssigned := TRUE;
                CarSlots[NewCarSlot] := TRUE;
            ELSIF NewCarSlot >= 51 AND NewCarSlot <= 100 THEN
                Elevator2Target := NewCarSlot;
                Elevator2Busy := TRUE;
                IsNewTaskAssigned := TRUE;
                CarSlots[NewCarSlot] := TRUE;
            END_IF;
        END_IF;
    END_IF;

    IF IsNewTaskAssigned = TRUE THEN
        Elevator1Position := Elevator1Target;
        Elevator2Position := Elevator2Target;
    ELSE
        Elevator1Position := Elevator1Position;
        Elevator2Position := Elevator2Position;
    END_IF;

    IF Elevator1Target = Elevator1Position THEN
        IsElevator1AtTarget := TRUE;
    ELSE
        IsElevator1AtTarget := FALSE;
    END_IF;

    IF Elevator2Target = Elevator2Position THEN
        IsElevator2AtTarget := TRUE;
    ELSE
        IsElevator2AtTarget := FALSE;
    END_IF;

    IF IsElevator1AtTarget = TRUE THEN
        IsElevator1Busy := FALSE;
    END_IF;

    IF IsElevator2AtTarget = TRUE THEN
        IsElevator2Busy := FALSE;
    END_IF;

    Elevator1Busy := IsElevator1Busy;
    Elevator2Busy := IsElevator2Busy;

END_FUNCTION_BLOCK