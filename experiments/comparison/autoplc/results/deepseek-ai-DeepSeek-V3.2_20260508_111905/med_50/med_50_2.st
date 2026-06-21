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
    i : INT; (* Loop variable for initialization *)
    bInitialized : BOOL; (* Flag for one-time initialization *)
END_VAR

(* Initialization - executed once on first call *)
IF NOT bInitialized THEN
    (* Initialize parking slots to unoccupied *)
    FOR i := 1 TO 100 DO
        CarSlots[i] := FALSE;
    END_FOR;
    
    (* Initialize elevator positions to starting position (floor 0) *)
    Elevator1Position := 0;
    Elevator2Position := 0;
    
    (* Initialize elevator targets to current positions *)
    Elevator1Target := 0;
    Elevator2Target := 0;
    
    (* Initialize elevator status to idle *)
    Elevator1Busy := FALSE;
    Elevator2Busy := FALSE;
    
    (* Initialize scanning counter *)
    CurrentSlot := 1;
    
    bInitialized := TRUE;
END_IF;

(* 1. Process new car arrival *)
IF (NewCarSlot >= 1) AND (NewCarSlot <= 100) THEN
    (* Check if slot is unoccupied *)
    IF NOT CarSlots[NewCarSlot] THEN
        (* Determine which elevator services this slot *)
        IF (NewCarSlot >= 1) AND (NewCarSlot <= 50) THEN
            (* Slot 1-50: Assign to Elevator 1 *)
            IF NOT Elevator1Busy THEN
                Elevator1Target := NewCarSlot;
                Elevator1Busy := TRUE;
                CarSlots[NewCarSlot] := TRUE; (* Mark slot as occupied *)
            END_IF;
        ELSE
            (* Slot 51-100: Assign to Elevator 2 *)
            IF NOT Elevator2Busy THEN
                Elevator2Target := NewCarSlot;
                Elevator2Busy := TRUE;
                CarSlots[NewCarSlot] := TRUE; (* Mark slot as occupied *)
            END_IF;
        END_IF;
    END_IF;
END_IF;

(* 2. Elevator movement logic *)
(* Elevator 1 movement *)
IF Elevator1Busy THEN
    IF Elevator1Position < Elevator1Target THEN
        (* Move elevator up *)
        Elevator1Position := Elevator1Position + 1;
    ELSIF Elevator1Position > Elevator1Target THEN
        (* Move elevator down *)
        Elevator1Position := Elevator1Position - 1;
    ELSE
        (* Reached target - mark as idle *)
        Elevator1Busy := FALSE;
        (* Ensure slot is marked as occupied *)
        IF (Elevator1Target >= 1) AND (Elevator1Target <= 100) THEN
            CarSlots[Elevator1Target] := TRUE;
        END_IF;
    END_IF;
END_IF;

(* Elevator 2 movement *)
IF Elevator2Busy THEN
    IF Elevator2Position < Elevator2Target THEN
        (* Move elevator up *)
        Elevator2Position := Elevator2Position + 1;
    ELSIF Elevator2Position > Elevator2Target THEN
        (* Move elevator down *)
        Elevator2Position := Elevator2Position - 1;
    ELSE
        (* Reached target - mark as idle *)
        Elevator2Busy := FALSE;
        (* Ensure slot is marked as occupied *)
        IF (Elevator2Target >= 1) AND (Elevator2Target <= 100) THEN
            CarSlots[Elevator2Target] := TRUE;
        END_IF;
    END_IF;
END_IF;

(* 3. Idle elevator scanning *)
(* Scan slots for Elevator 1 range (1-50) when idle *)
IF NOT Elevator1Busy THEN
    (* Check current slot in range 1-50 *)
    IF (CurrentSlot >= 1) AND (CurrentSlot <= 50) THEN
        (* Monitor slot status - no action needed as scanning is for monitoring only *)
        (* Slot status is already tracked in CarSlots array *)
    END_IF;
END_IF;

(* Scan slots for Elevator 2 range (51-100) when idle *)
IF NOT Elevator2Busy THEN
    (* Check current slot in range 51-100 *)
    IF (CurrentSlot >= 51) AND (CurrentSlot <= 100) THEN
        (* Monitor slot status - no action needed as scanning is for monitoring only *)
        (* Slot status is already tracked in CarSlots array *)
    END_IF;
END_IF;

(* Increment scanning counter and wrap around *)
CurrentSlot := CurrentSlot + 1;
IF CurrentSlot > 100 THEN
    CurrentSlot := 1;
END_IF;

END_FUNCTION_BLOCK