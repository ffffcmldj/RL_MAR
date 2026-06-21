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

(* Process new car arrival *)
IF (NewCarSlot >= 1) AND (NewCarSlot <= 100) THEN
    IF NOT CarSlots[NewCarSlot] THEN
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
        CarSlots[NewCarSlot] := TRUE;
    END_IF;
END_IF;

(* Elevator 1 motion control *)
IF Elevator1Busy THEN
    IF Elevator1Position < Elevator1Target THEN
        Elevator1Position := Elevator1Position + 1;
    ELSIF Elevator1Position > Elevator1Target THEN
        Elevator1Position := Elevator1Position - 1;
    ELSE
        Elevator1Busy := FALSE;
    END_IF;
ELSE
    (* Idle: scan for new tasks in assigned range (slots 1-50) *)
    FOR CurrentSlot := 1 TO 50 DO
        IF CarSlots[CurrentSlot] THEN
            Elevator1Target := CurrentSlot;
            Elevator1Busy := TRUE;
            EXIT;
        END_IF;
    END_FOR;
END_IF;

(* Elevator 2 motion control *)
IF Elevator2Busy THEN
    IF Elevator2Position < Elevator2Target THEN
        Elevator2Position := Elevator2Position + 1;
    ELSIF Elevator2Position > Elevator2Target THEN
        Elevator2Position := Elevator2Position - 1;
    ELSE
        Elevator2Busy := FALSE;
    END_IF;
ELSE
    (* Idle: scan for new tasks in assigned range (slots 51-100) *)
    FOR CurrentSlot := 51 TO 100 DO
        IF CarSlots[CurrentSlot] THEN
            Elevator2Target := CurrentSlot;
            Elevator2Busy := TRUE;
            EXIT;
        END_IF;
    END_FOR;
END_IF;

END_FUNCTION_BLOCK;