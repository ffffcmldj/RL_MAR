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
    bScanComplete : BOOL; (* Flag to indicate slot scanning completion *)
END_VAR

(* Initialize variables *)
IF NOT bScanComplete THEN
    Elevator1Target := 0;
    Elevator2Target := 0;
    Elevator1Position := 0;
    Elevator2Position := 0;
    Elevator1Busy := FALSE;
    Elevator2Busy := FALSE;
    CurrentSlot := 1;
    bScanComplete := TRUE;
    
    (* Clear all parking slots *)
    FOR CurrentSlot := 1 TO 100 DO
        CarSlots[CurrentSlot] := FALSE;
    END_FOR;
END_IF;

(* Process new car arrival *)
IF NewCarSlot >= 1 AND NewCarSlot <= 100 THEN
    IF NOT CarSlots[NewCarSlot] THEN
        CarSlots[NewCarSlot] := TRUE;
        
        (* Assign elevator based on slot range *)
        IF NewCarSlot <= 50 THEN
            IF NOT Elevator1Busy THEN
                Elevator1Target := NewCarSlot;
                Elevator1Busy := TRUE;
            END_IF;
        ELSE
            IF NOT Elevator2Busy THEN
                Elevator2Target := NewCarSlot;
                Elevator2Busy := TRUE;
            END_IF;
        END_IF;
    END_IF;
END_IF;

(* Elevator 1 movement logic *)
IF Elevator1Busy THEN
    IF Elevator1Position < Elevator1Target THEN
        Elevator1Position := Elevator1Position + 1;
    ELSIF Elevator1Position > Elevator1Target THEN
        Elevator1Position := Elevator1Position - 1;
    ELSE
        (* Reached target - mark as idle *)
        Elevator1Busy := FALSE;
        Elevator1Target := 0;
    END_IF;
END_IF;

(* Elevator 2 movement logic *)
IF Elevator2Busy THEN
    IF Elevator2Position < Elevator2Target THEN
        Elevator2Position := Elevator2Position + 1;
    ELSIF Elevator2Position > Elevator2Target THEN
        Elevator2Position := Elevator2Position - 1;
    ELSE
        (* Reached target - mark as idle *)
        Elevator2Busy := FALSE;
        Elevator2Target := 0;
    END_IF;
END_IF;

(* Scan for new tasks - only scan when both elevators are idle *)
IF NOT Elevator1Busy AND NOT Elevator2Busy THEN
    FOR CurrentSlot := 1 TO 100 DO
        IF CarSlots[CurrentSlot] THEN
            (* Assign to appropriate elevator *)
            IF CurrentSlot <= 50 THEN
                Elevator1Target := CurrentSlot;
                Elevator1Busy := TRUE;
                EXIT; (* Exit loop after assigning one task *)
            ELSE
                Elevator2Target := CurrentSlot;
                Elevator2Busy := TRUE;
                EXIT; (* Exit loop after assigning one task *)
            END_IF;
        END_IF;
    END_FOR;
END_IF;

END_FUNCTION_BLOCK