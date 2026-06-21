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
    Elevator1Moving : BOOL; (* Internal flag for elevator 1 movement *)
    Elevator2Moving : BOOL; (* Internal flag for elevator 2 movement *)
    Initialized : BOOL := FALSE; (* System initialization flag *)
END_VAR

(* System initialization - runs once *)
IF NOT Initialized THEN
    FOR CurrentSlot := 1 TO 100 DO
        CarSlots[CurrentSlot] := FALSE;
    END_FOR;
    Elevator1Target := 0;
    Elevator2Target := 0;
    Elevator1Position := 0;
    Elevator2Position := 0;
    Elevator1Busy := FALSE;
    Elevator2Busy := FALSE;
    Elevator1Moving := FALSE;
    Elevator2Moving := FALSE;
    Initialized := TRUE;
END_IF;

(* Process new car arrival *)
IF (NewCarSlot >= 1) AND (NewCarSlot <= 100) THEN
    IF NOT CarSlots[NewCarSlot] THEN
        CarSlots[NewCarSlot] := TRUE;
        
        (* Assign to appropriate elevator based on slot range *)
        IF (NewCarSlot <= 50) AND NOT Elevator1Busy THEN
            Elevator1Target := NewCarSlot;
            Elevator1Busy := TRUE;
            Elevator1Moving := TRUE;
        ELSIF (NewCarSlot >= 51) AND NOT Elevator2Busy THEN
            Elevator2Target := NewCarSlot;
            Elevator2Busy := TRUE;
            Elevator2Moving := TRUE;
        END_IF;
    END_IF;
END_IF;

(* Elevator 1 movement control *)
IF Elevator1Moving THEN
    IF Elevator1Position < Elevator1Target THEN
        Elevator1Position := Elevator1Position + 1;
    ELSIF Elevator1Position > Elevator1Target THEN
        Elevator1Position := Elevator1Position - 1;
    ELSE
        (* Reached target *)
        Elevator1Moving := FALSE;
        Elevator1Busy := FALSE;
    END_IF;
END_IF;

(* Elevator 2 movement control *)
IF Elevator2Moving THEN
    IF Elevator2Position < Elevator2Target THEN
        Elevator2Position := Elevator2Position + 1;
    ELSIF Elevator2Position > Elevator2Target THEN
        Elevator2Position := Elevator2Position - 1;
    ELSE
        (* Reached target *)
        Elevator2Moving := FALSE;
        Elevator2Busy := FALSE;
    END_IF;
END_IF;

(* Idle elevator scanning for new arrivals - Elevator 1 scans slots 1-50 *)
IF NOT Elevator1Busy THEN
    FOR CurrentSlot := 1 TO 50 DO
        IF CarSlots[CurrentSlot] THEN
            Elevator1Target := CurrentSlot;
            Elevator1Busy := TRUE;
            Elevator1Moving := TRUE;
            EXIT;
        END_IF;
    END_FOR;
END_IF;

(* Idle elevator scanning for new arrivals - Elevator 2 scans slots 51-100 *)
IF NOT Elevator2Busy THEN
    FOR CurrentSlot := 51 TO 100 DO
        IF CarSlots[CurrentSlot] THEN
            Elevator2Target := CurrentSlot;
            Elevator2Busy := TRUE;
            Elevator2Moving := TRUE;
            EXIT;
        END_IF;
    END_FOR;
END_IF;

END_FUNCTION_BLOCK