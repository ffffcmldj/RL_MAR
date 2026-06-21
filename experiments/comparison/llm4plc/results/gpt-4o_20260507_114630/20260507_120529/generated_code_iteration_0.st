plaintext
START_ST
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
    state : INT; (* Current state of the system *)
    Elevator1Target : INT; (* Target position for Elevator 1 *)
    Elevator2Target : INT; (* Target position for Elevator 2 *)
    CarSlots : ARRAY[1..100] OF BOOL; (* Array to represent parking slots - TRUE if occupied *)
    CurrentSlot : INT; (* Loop counter for scanning slots *)
END_VAR

(* Initialization of variables *)
IF NOT INIT THEN
    state := 0; (* Start in IDLE state *)
    Elevator1Busy := FALSE;
    Elevator2Busy := FALSE;
    Elevator1Position := 0;
    Elevator2Position := 0;
    Elevator1Target := 0;
    Elevator2Target := 0;
    FOR CurrentSlot := 1 TO 100 DO
        CarSlots[CurrentSlot] := FALSE; (* Initialize all slots as unoccupied *)
    END_FOR;
    INIT := TRUE;
END_IF;

(* State Machine *)
CASE state OF
    (* STATE 0: IDLE *)
    0:
        Elevator1Busy := FALSE;
        Elevator2Busy := FALSE;
        IF NewCarSlot > 0 THEN
            state := 1; (* Transition to ASSIGN ELEVATOR state *)
        END_IF;

    (* STATE 1: ASSIGN ELEVATOR *)
    1:
        IF (NewCarSlot >= 1 AND NewCarSlot <= 50) AND (Elevator1Busy = FALSE) THEN
            Elevator1Target := NewCarSlot;
            Elevator1Busy := TRUE;
            state := 2; (* Transition to MOVE ELEVATOR 1 state *)
        ELSIF (NewCarSlot >= 51 AND NewCarSlot <= 100) AND (Elevator2Busy = FALSE) THEN
            Elevator2Target := NewCarSlot;
            Elevator2Busy := TRUE;
            state := 3; (* Transition to MOVE ELEVATOR 2 state *)
        END_IF;

    (* STATE 2: MOVE ELEVATOR 1 *)
    2:
        IF Elevator1Position < Elevator1Target THEN
            Elevator1Position := Elevator1Position + 1; (* Move Elevator 1 up *)
        ELSIF Elevator1Position > Elevator1Target THEN
            Elevator1Position := Elevator1Position - 1; (* Move Elevator 1 down *)
        ELSE
            state := 4; (* Transition to UPDATE SLOT STATUS state *)
        END_IF;

    (* STATE 3: MOVE ELEVATOR 2 *)
    3:
        IF Elevator2Position < Elevator2Target THEN
            Elevator2Position := Elevator2Position + 1; (* Move Elevator 2 up *)
        ELSIF Elevator2Position > Elevator2Target THEN
            Elevator2Position := Elevator2Position - 1; (* Move Elevator 2 down *)
        ELSE
            state := 4; (* Transition to UPDATE SLOT STATUS state *)
        END_IF;

    (* STATE 4: UPDATE SLOT STATUS *)
    4:
        CarSlots[NewCarSlot] := TRUE; (* Mark the slot as occupied *)
        NewCarSlot := 0; (* Reset NewCarSlot to indicate task completion *)
        IF Elevator1Position = Elevator1Target THEN
            Elevator1Busy := FALSE; (* Mark Elevator 1 as idle *)
        END_IF;
        IF Elevator2Position = Elevator2Target THEN
            Elevator2Busy := FALSE; (* Mark Elevator 2 as idle *)
        END_IF;
        IF (Elevator1Busy = FALSE) AND (Elevator2Busy = FALSE) THEN
            state := 0; (* Transition back to IDLE state *)
        END_IF;
END_CASE;

END_FUNCTION_BLOCK
END_ST