(* Multi-Level Car Parking System Control *)
(* FUNCTION_BLOCK: CarParkingSystem *)
(* Manages two elevators for 100 parking slots with slot-based allocation *)
(* Slot Range Allocation: Slots 1-50 -> Elevator 1, Slots 51-100 -> Elevator 2 *)

FUNCTION_BLOCK CarParkingSystem
VAR_INPUT
    NewCarSlot : INT; (* New car arrival slot number (1-100) *)
END_VAR
VAR_OUTPUT
    Elevator1Busy : BOOL; (* Elevator 1 status: TRUE=busy, FALSE=idle *)
    Elevator2Busy : BOOL; (* Elevator 2 status: TRUE=busy, FALSE=idle *)
    Elevator1Position : INT; (* Elevator 1 current position (1-100) *)
    Elevator2Position : INT; (* Elevator 2 current position (1-100) *)
END_VAR
VAR
    Elevator1Target : INT; (* Elevator 1 target position *)
    Elevator2Target : INT; (* Elevator 2 target position *)
    CarSlots : ARRAY[1..100] OF BOOL; (* Slot occupancy: TRUE=occupied *)
    CurrentSlot : INT; (* Loop counter for slot scanning *)
    NewCarProcessed : BOOL; (* Flag to track new car processing *)
END_VAR

(* Main Execution Logic *)

(* 1. Elevator Movement Simulation *)
(* Elevator 1 Movement *)
IF Elevator1Busy THEN
    IF Elevator1Position < Elevator1Target THEN
        Elevator1Position := Elevator1Position + 1;
    ELSIF Elevator1Position > Elevator1Target THEN
        Elevator1Position := Elevator1Position - 1;
    ELSE
        (* Reached target - set to idle *)
        Elevator1Busy := FALSE;
    END_IF;
END_IF;

(* Elevator 2 Movement *)
IF Elevator2Busy THEN
    IF Elevator2Position < Elevator2Target THEN
        Elevator2Position := Elevator2Position + 1;
    ELSIF Elevator2Position > Elevator2Target THEN
        Elevator2Position := Elevator2Position - 1;
    ELSE
        (* Reached target - set to idle *)
        Elevator2Busy := FALSE;
    END_IF;
END_IF;

(* 2. Process New Car Arrival *)
(* Reset processed flag at start of each scan *)
NewCarProcessed := FALSE;

(* Validate and process new car arrival *)
IF (NewCarSlot >= 1) AND (NewCarSlot <= 100) THEN
    IF NOT CarSlots[NewCarSlot] THEN
        (* Mark slot as occupied *)
        CarSlots[NewCarSlot] := TRUE;
        
        (* Assign to appropriate elevator based on slot range *)
        IF (NewCarSlot <= 50) THEN
            (* Assign to Elevator 1 if idle *)
            IF NOT Elevator1Busy THEN
                Elevator1Target := NewCarSlot;
                Elevator1Busy := TRUE;
                NewCarProcessed := TRUE;
            END_IF;
        ELSE
            (* Assign to Elevator 2 if idle *)
            IF NOT Elevator2Busy THEN
                Elevator2Target := NewCarSlot;
                Elevator2Busy := TRUE;
                NewCarProcessed := TRUE;
            END_IF;
        END_IF;
    END_IF;
END_IF;

(* 3. Idle Elevator Scanning for Pending Tasks *)
(* Only scan if new car wasn't immediately assigned *)

(* Elevator 1 scans slots 1-50 *)
IF NOT Elevator1Busy THEN
    FOR CurrentSlot := 1 TO 50 DO
        IF CarSlots[CurrentSlot] THEN
            (* Found occupied slot - assign to elevator *)
            Elevator1Target := CurrentSlot;
            Elevator1Busy := TRUE;
            CarSlots[CurrentSlot] := FALSE; (* Clear after assignment *)
            EXIT; (* Exit loop after first found slot *)
        END_IF;
    END_FOR;
END_IF;

(* Elevator 2 scans slots 51-100 *)
IF NOT Elevator2Busy THEN
    FOR CurrentSlot := 51 TO 100 DO
        IF CarSlots[CurrentSlot] THEN
            (* Found occupied slot - assign to elevator *)
            Elevator2Target := CurrentSlot;
            Elevator2Busy := TRUE;
            CarSlots[CurrentSlot] := FALSE; (* Clear after assignment *)
            EXIT; (* Exit loop after first found slot *)
        END_IF;
    END_FOR;
END_IF;

END_FUNCTION_BLOCK;