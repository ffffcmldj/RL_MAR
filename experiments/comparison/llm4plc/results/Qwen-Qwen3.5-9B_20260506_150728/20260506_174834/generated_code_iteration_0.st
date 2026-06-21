START_ST
FUNCTION_BLOCK ParcelSortingSystem
VAR_INPUT
    ParcelSizeSensor : REAL; (* Sensor input for parcel size *)
    DestinationCodeSensor : INT; (* Destination code: 1=A, 2=B *)
END_VAR
VAR_OUTPUT
    ConveyorBeltMotor : BOOL; (* Output for conveyor belt motor: TRUE=On, FALSE=Off *)
    SortingGate1 : BOOL; (* Output for sorting gate 1: TRUE=Open, FALSE=Closed *)
    SortingGate2 : BOOL; (* Output for sorting gate 2: TRUE=Open, FALSE=Closed *)
END_VAR

VAR
    (* 0. DECLARE THE NEEDED STATES *)
    CurrentState : INT; (* Current FSM State: 0=Idle/Err, 1=ProcessLarge, 2=ProcessSmallA, 3=ProcessSmallB *)
    ParcelSizeThreshold : REAL; (* Threshold to distinguish Large vs Small *)
    
    (* 1. LIST THE OUTPUT VALUES FOR EACH STATE - INTERNAL FLAGS *)
    ConveyorOn : BOOL; (* Internal flag to track conveyor status *)
    Gate1On : BOOL; (* Internal flag for Gate 1 *)
    Gate2On : BOOL; (* Internal flag for Gate 2 *)
    
    (* 2. LIST THE TRANSITIONS LOGIC HELPERS *)
    IsLargeParcel : BOOL; (* Helper: Is current parcel large? *)
    IsValidDestination : BOOL; (* Helper: Is destination code 1 or 2? *)
    IsErrorCondition : BOOL; (* Helper: Is input invalid? *)
    
    (* 3. DECLARE THE NEEDED VARIABLES - PREVIOUS STATE TRACKING *)
    PreviousState : INT; (* Previous state to ensure stable transitions if needed *)
END_VAR

(* Initialize variables on first execution or reset if needed *)
IF CurrentState = 0 AND PreviousState = 0 THEN
    CurrentState := 0;
    ParcelSizeThreshold := 50.0; (* Default threshold in mm, configurable *)
END_IF;

(* --- STATE MACHINE LOGIC --- *)

(* Determine parcel characteristics based on inputs *)
IsLargeParcel := (ParcelSizeSensor >= ParcelSizeThreshold);
IsValidDestination := (DestinationCodeSensor = 1 OR DestinationCodeSensor = 2);
IsErrorCondition := (NOT IsValidDestination);

(* --- STATE 0: IDLE / ERROR --- *)
IF CurrentState = 0 THEN
    (* Action: Conveyor OFF, Both Gates CLOSED *)
    ConveyorOn := FALSE;
    Gate1On := FALSE;
    Gate2On := FALSE;
    
    (* Transition Logic *)
    IF IsLargeParcel THEN
        (* Transition to STATE 1: PROCESS_LARGE *)
        CurrentState := 1;
    ELSIF IsValidDestination THEN
        (* Transition to STATE 2 or 3 based on destination code *)
        IF DestinationCodeSensor = 1 THEN
            CurrentState := 2; (* PROCESS_SMALL_DEST_A *)
        ELSIF DestinationCodeSensor = 2 THEN
            CurrentState := 3; (* PROCESS_SMALL_DEST_B *)
        END_IF;
    ELSE
        (* Remain in STATE 0 (Error) if inputs are invalid *)
        CurrentState := 0;
    END_IF;
    
    PreviousState := CurrentState;
END_IF;

(* --- STATE 1: PROCESS_LARGE --- *)
IF CurrentState = 1 THEN
    (* Action: Conveyor ON, SortingGate1 OPEN, SortingGate2 CLOSED *)
    ConveyorOn := TRUE;
    Gate1On := TRUE;
    Gate2On := FALSE;
    
    (* Transition Logic: Exit when parcel passes (size drops below threshold) *)
    IF (NOT IsLargeParcel) OR (ParcelSizeSensor = 0.0) THEN
        (* Transition to STATE 0: IDLE/ERROR *)
        CurrentState := 0;
    END_IF;
    
    PreviousState := CurrentState;
END_IF;

(* --- STATE 2: PROCESS_SMALL_DEST_A --- *)
IF CurrentState = 2 THEN
    (* Action: Conveyor ON, SortingGate1 CLOSED, SortingGate2 OPEN *)
    ConveyorOn := TRUE;
    Gate1On := FALSE;
    Gate2On := TRUE;
    
    (* Transition Logic: Exit when parcel passes (size drops below threshold) *)
    IF (NOT IsLargeParcel) OR (ParcelSizeSensor = 0.0) THEN
        (* Transition to STATE 0: IDLE/ERROR *)
        CurrentState := 0;
    END_IF;
    
    PreviousState := CurrentState;
END_IF;

(* --- STATE 3: PROCESS_SMALL_DEST_B --- *)
IF CurrentState = 3 THEN
    (* Action: Conveyor ON, SortingGate1 CLOSED, SortingGate2 CLOSED *)
    ConveyorOn := TRUE;
    Gate1On := FALSE;
    Gate2On := FALSE;
    
    (* Transition Logic: Exit when parcel passes (size drops below threshold) *)
    IF (NOT IsLargeParcel) OR (ParcelSizeSensor = 0.0) THEN
        (* Transition to STATE 0: IDLE/ERROR *)
        CurrentState := 0;
    END_IF;
    
    PreviousState := CurrentState;
END_IF;

(* --- STATE 4: RESET / RECOVER --- *)
(* Note: Based on the plan, State 4 acts as a recovery phase. 
   Since the primary transition logic moves directly from processing states back to State 0,
   and State 0 handles the "Conveyor OFF, Gates Closed" requirement, 
   State 4 is effectively merged into State 0 behavior for this specific logic flow 
   unless a specific timer or external reset signal is required. 
   The plan description for State 4 says "Conveyor is OFF, Both Gates are CLOSED", 
   which is identical to State 0. We rely on State 0 to handle the idle/error condition. *)

(* --- ASSIGN OUTPUTS TO POU OUTPUTS --- *)
(* Ensure outputs are always updated based on current state logic *)
ConveyorBeltMotor := ConveyorOn;
SortingGate1 := Gate1On;
SortingGate2 := Gate2On;

END_FUNCTION_BLOCK
END_ST