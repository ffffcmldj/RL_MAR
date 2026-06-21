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

    // Initialization
    IF NOT Elevator1Busy AND NOT Elevator2Busy THEN
        FOR CurrentSlot := 1 TO 100 DO
            CarSlots[CurrentSlot] := FALSE; // Set all slots to available
        END_FOR;
        Elevator1Position := 1; // Starting position for Elevator 1
        Elevator2Position := 51; // Starting position for Elevator 2
        Elevator1Busy := FALSE; // Set Elevator 1 to idle
        Elevator2Busy := FALSE; // Set Elevator 2 to idle
    END_IF;

    // Car Arrival Handling
    IF NewCarSlot >= 1 AND NewCarSlot <= 100 THEN
        IF NOT CarSlots[NewCarSlot] THEN // Check if the slot is available
            CarSlots[NewCarSlot] := TRUE; // Mark the slot as occupied

            // Elevator Assignment
            IF NewCarSlot <= 50 THEN
                Elevator1Target := NewCarSlot; // Assign Elevator 1
                Elevator1Busy := TRUE; // Set Elevator 1 to busy
            ELSE
                Elevator2Target := NewCarSlot; // Assign Elevator 2
                Elevator2Busy := TRUE; // Set Elevator 2 to busy
            END_IF;
        END_IF;
    END_IF;

    // Elevator Movement
    IF Elevator1Busy THEN
        IF Elevator1Position < Elevator1Target THEN
            Elevator1Position := Elevator1Position + 1; // Move Elevator 1 up
        ELSIF Elevator1Position > Elevator1Target THEN
            Elevator1Position := Elevator1Position - 1; // Move Elevator 1 down
        END_IF;

        // Check if Elevator 1 has reached the target
        IF Elevator1Position = Elevator1Target THEN
            Elevator1Busy := FALSE; // Set Elevator 1 to idle
        END_IF;
    END_IF;

    IF Elevator2Busy THEN
        IF Elevator2Position < Elevator2Target THEN
            Elevator2Position := Elevator2Position + 1; // Move Elevator 2 up
        ELSIF Elevator2Position > Elevator2Target THEN
            Elevator2Position := Elevator2Position - 1; // Move Elevator 2 down
        END_IF;

        // Check if Elevator 2 has reached the target
        IF Elevator2Position = Elevator2Target THEN
            Elevator2Busy := FALSE; // Set Elevator 2 to idle
        END_IF;
    END_IF;
END_FUNCTION_BLOCK