FUNCTION_BLOCK CarParkingSystem
    VAR_INPUT
        NewCarSlot : INT; (* Input for new car arrival slot number *)
    END_VAR
    VAR_OUTPUT
        Elevator1Busy : BOOL; (* Elevator 1 status - busy or idle *)
        Elevator2Busy : BOOL; (* Elevator 2 status - busy or idle *)
        Elevator1Position : INT; (* Elevator 1 current position *)
        Elevator2Position : INT; (* Elevator 2 current position *)
    END_VAR
    VAR
        Elevator1Target : INT; (* Elevator 1 target floor *)
        Elevator2Target : INT; (* Elevator 2 target floor *)
        CarSlots : ARRAY[1..100] OF BOOL; (* Array to represent parking slots - TRUE if occupied *)
        CurrentSlot : INT; (* Loop counter for scanning slots *)
    END_VAR

    (* Initialization *)
    FOR CurrentSlot := 1 TO 100 DO
        CarSlots[CurrentSlot] := FALSE; (* Initialize all slots to unoccupied *)
    END_FOR
    Elevator1Busy := FALSE; (* Initialize Elevator 1 to idle *)
    Elevator2Busy := FALSE; (* Initialize Elevator 2 to idle *)
    Elevator1Position := 0; (* Default starting position for Elevator 1 *)
    Elevator2Position := 0; (* Default starting position for Elevator 2 *)

    (* Car Arrival Handling *)
    IF NewCarSlot > 0 AND NewCarSlot <= 100 THEN
        IF NOT CarSlots[NewCarSlot] THEN (* Check if the slot is unoccupied *)
            CarSlots[NewCarSlot] := TRUE; (* Mark the slot as occupied *)

            (* Elevator Assignment *)
            IF NewCarSlot <= 50 THEN
                Elevator1Target := NewCarSlot;
                Elevator1Busy := TRUE;
            ELSE
                Elevator2Target := NewCarSlot;
                Elevator2Busy := TRUE;
            END_IF
        END_IF
    END_IF

    (* Elevator Movement *)
    IF Elevator1Busy THEN
        IF Elevator1Position < Elevator1Target THEN
            Elevator1Position := Elevator1Position + 1; (* Move Elevator 1 towards target *)
        ELSIF Elevator1Position > Elevator1Target THEN
            Elevator1Position := Elevator1Position - 1; (* Move Elevator 1 towards target *)
        ELSE
            Elevator1Busy := FALSE; (* Task completed, set Elevator 1 to idle *)
        END_IF
    END_IF

    IF Elevator2Busy THEN
        IF Elevator2Position < Elevator2Target THEN
            Elevator2Position := Elevator2Position + 1; (* Move Elevator 2 towards target *)
        ELSIF Elevator2Position > Elevator2Target THEN
            Elevator2Position := Elevator2Position - 1; (* Move Elevator 2 towards target *)
        ELSE
            Elevator2Busy := FALSE; (* Task completed, set Elevator 2 to idle *)
        END_IF
    END_IF

END_FUNCTION_BLOCK