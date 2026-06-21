(*
    FUNCTION_BLOCK: Automated_Parking_Controller
    DESCRIPTION: Manages a multi-level car parking system with up to 100 spaces.
                 Handles entry gate allocation, exit gate release, and car retrieval.
    AUTHOR: Senior PLC Commissioning Engineer
    STANDARD: IEC 61131-3
*)

FUNCTION_BLOCK Automated_Parking_Controller
VAR_INPUT
    EntryGateSensor : BOOL; (* Rising edge triggers entry allocation *)
    ExitGateSensor  : BOOL; (* Rising edge triggers space release *)
    CarDetected     : BOOL; (* Rising edge triggers retrieval process *)
END_VAR

VAR_OUTPUT
    ParkingSpaceNumber  : INT := 0;  (* 0 = no allocation, 1-100 = allocated space *)
    RetrievalInProgress : BOOL := FALSE;
END_VAR

VAR
    (* Main parking space tracking array *)
    ParkingSpaces : ARRAY[1..100] OF BOOL := [100(FALSE)];
    
    (* Internal state management *)
    CurrentState    : INT := 0;
    AssignedSpace   : INT := 0;
    RetrievalSpace  : INT := 0;
    
    (* Edge detection for input signals *)
    EntryGateSensor_Prev  : BOOL := FALSE;
    ExitGateSensor_Prev   : BOOL := FALSE;
    CarDetected_Prev      : BOOL := FALSE;
    
    (* Temporary variables *)
    i : INT;
END_VAR

(* State Definitions:
   0: IDLE - Waiting for events
   1: ENTRY_PROCESSING - Car entering, waiting for sensor reset
   2: RETRIEVAL_PROCESSING - Executing car movement to exit
   3: EXIT_PROCESSING - Car exiting, waiting for sensor reset
*)

CASE CurrentState OF
    0: (* IDLE STATE - Monitor for events *)
        (* Entry Gate Processing *)
        IF (EntryGateSensor AND NOT EntryGateSensor_Prev) AND NOT RetrievalInProgress THEN
            AssignedSpace := 0;
            
            (* Find first available parking space *)
            FOR i := 1 TO 100 DO
                IF NOT ParkingSpaces[i] THEN
                    AssignedSpace := i;
                    EXIT;
                END_IF;
            END_FOR;
            
            (* If space found, allocate it *)
            IF AssignedSpace > 0 THEN
                ParkingSpaces[AssignedSpace] := TRUE;
                ParkingSpaceNumber := AssignedSpace;
                CurrentState := 1; (* Move to entry processing *)
            END_IF;
        
        (* Car Retrieval Initiation *)
        ELSIF (CarDetected AND NOT CarDetected_Prev) AND NOT RetrievalInProgress THEN
            IF ParkingSpaceNumber > 0 THEN
                RetrievalInProgress := TRUE;
                RetrievalSpace := ParkingSpaceNumber;
                CurrentState := 2; (* Move to retrieval processing *)
            END_IF;
        END_IF;
    
    1: (* ENTRY_PROCESSING STATE - Wait for car to clear entry gate *)
        IF NOT EntryGateSensor THEN
            CurrentState := 0; (* Return to idle *)
        END_IF;
    
    2: (* RETRIEVAL_PROCESSING STATE - Execute car movement to exit *)
        IF MoveCarToExitGate(RetrievalSpace) THEN
            (* Clear the parking space *)
            ParkingSpaces[RetrievalSpace] := FALSE;
            ParkingSpaceNumber := 0;
            RetrievalSpace := 0;
            CurrentState := 3; (* Move to exit processing *)
        END_IF;
    
    3: (* EXIT_PROCESSING STATE - Wait for car to clear exit gate *)
        IF ExitGateSensor THEN
            RetrievalInProgress := FALSE;
            CurrentState := 0; (* Return to idle *)
        END_IF;
END_CASE;

(* Handle direct exit (without retrieval request) *)
IF (ExitGateSensor AND NOT ExitGateSensor_Prev) AND NOT RetrievalInProgress AND (CurrentState = 0) THEN
    IF ParkingSpaceNumber > 0 THEN
        ParkingSpaces[ParkingSpaceNumber] := FALSE;
        ParkingSpaceNumber := 0;
    END_IF;
END_IF;

(* Update edge detection registers *)
EntryGateSensor_Prev := EntryGateSensor;
ExitGateSensor_Prev := ExitGateSensor;
CarDetected_Prev := CarDetected;

END_FUNCTION_BLOCK

(*
    FUNCTION: MoveCarToExitGate
    DESCRIPTION: Simulates the movement of a car from its parking space to the exit gate.
                 In a real system, this would interface with physical movement mechanisms.
    INPUT: SpaceNumber - The parking space number to retrieve from
    OUTPUT: TRUE when movement is complete
*)
FUNCTION MoveCarToExitGate : BOOL
VAR_INPUT
    SpaceNumber : INT;
END_VAR

(* In this simplified implementation, movement is considered instantaneous.
   In a real application, this function would coordinate with motor controls,
   safety sensors, and position feedback. *)
MoveCarToExitGate := TRUE;

END_FUNCTION