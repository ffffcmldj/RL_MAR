plaintext
START_ST
FUNCTION_BLOCK Automated_Parking_Controller
VAR_INPUT
    EntryGateSensor : BOOL; (* Sensor input for entry gate *)
    ExitGateSensor : BOOL; (* Sensor input for exit gate *)
    CarDetected : BOOL; (* Sensor input for car detection *)
END_VAR
VAR_OUTPUT
    ParkingSpaceNumber : INT := 0; (* Allocated parking space number *)
    RetrievalInProgress : BOOL := FALSE; (* Flag for car retrieval in progress *)
END_VAR
VAR
    state : INT := 0; (* Current state of the system *)
    prevState : INT := 0; (* Previous state of the system *)
    ParkingSpaces : ARRAY[1..100] OF BOOL := [FALSE(FALSE)]; (* Parking space status: TRUE=Occupied, FALSE=Available *)
    i : INT; (* Loop counter for scanning parking spaces *)
    SpaceNumber : INT := 0; (* Space number for car retrieval *)
    MoveComplete : BOOL := FALSE; (* Status of car movement *)
END_VAR

(* State Machine Logic *)
CASE state OF
    (* STATE 0: IDLE *)
    0:
        IF EntryGateSensor AND NOT RetrievalInProgress THEN
            prevState := state;
            state := 1; (* Transition to ALLOCATE_PARKING *)
        ELSIF CarDetected THEN
            prevState := state;
            state := 2; (* Transition to RETRIEVE_CAR *)
        ELSIF ExitGateSensor THEN
            prevState := state;
            state := 3; (* Transition to EXIT_CAR *)
        END_IF;

    (* STATE 1: ALLOCATE_PARKING *)
    1:
        FOR i := 1 TO 100 DO
            IF NOT ParkingSpaces[i] THEN
                ParkingSpaces[i] := TRUE; (* Mark space as occupied *)
                ParkingSpaceNumber := i; (* Assign parking space number *)
                EXIT; (* Exit loop after finding the first available space *)
            END_IF;
        END_FOR;
        state := 0; (* Transition back to IDLE *)

    (* STATE 2: RETRIEVE_CAR *)
    2:
        RetrievalInProgress := TRUE; (* Set retrieval in progress flag *)
        SpaceNumber := ParkingSpaceNumber; (* Identify the space to retrieve *)
        state := 4; (* Transition to MOVE_CAR_TO_EXIT *)

    (* STATE 3: EXIT_CAR *)
    3:
        ParkingSpaces[ParkingSpaceNumber] := FALSE; (* Mark space as available *)
        ParkingSpaceNumber := 0; (* Reset parking space number *)
        state := 0; (* Transition back to IDLE *)

    (* STATE 4: MOVE_CAR_TO_EXIT *)
    4:
        MoveComplete := MoveCarToExitGate(SpaceNumber); (* Call helper function *)
        IF MoveComplete THEN
            state := 3; (* Transition to EXIT_CAR after movement is complete *)
        END_IF;

    (* Default case to handle unexpected states *)
    ELSE
        state := 0; (* Reset to IDLE *)
END_CASE;

END_FUNCTION_BLOCK

FUNCTION MoveCarToExitGate : BOOL
VAR_INPUT
    SpaceNumber : INT; (* Space number of the car to be moved *)
END_VAR
VAR
    MovementComplete : BOOL := FALSE; (* Status of car movement *)
END_VAR

(* Simulate car movement logic *)
IF SpaceNumber > 0 AND SpaceNumber <= 100 THEN
    (* Simulate successful movement *)
    MovementComplete := TRUE;
END_IF;

MoveCarToExitGate := MovementComplete; (* Return movement status *)

END_FUNCTION
END_ST