START_REASON
The previous code failed CODESYS compiler validation (Error 500) primarily due to the use of a `VAR` section containing `IF` statements for initialization. In IEC 61131-3 Structured Text, variable declarations (`VAR`, `VAR_INPUT`, `VAR_OUTPUT`) must be followed by a single `END_VAR` immediately. Logic (like initialization `IF` statements) must be placed in the executable body of the function block, not inside the declaration section.

Additionally, the code used `PreviousState` in the initialization logic without declaring it in the `VAR` section before the `END_VAR` of the declaration block. The corrected code moves the initialization logic to the body, ensures all variables are declared before `END_VAR`, and maintains the Function Block structure.
END_REASON

START_ST
FUNCTION_BLOCK ParcelSortingSystem
VAR_INPUT
    ParcelSizeSensor : REAL;
    DestinationCodeSensor : INT;
END_VAR
VAR_OUTPUT
    ConveyorBeltMotor : BOOL;
    SortingGate1 : BOOL;
    SortingGate2 : BOOL;
END_VAR

VAR
    CurrentState : INT := 0;
    ParcelSizeThreshold : REAL := 50.0;
    PreviousState : INT := 0;
    
    ConveyorOn : BOOL;
    Gate1On : BOOL;
    Gate2On : BOOL;
    
    IsLargeParcel : BOOL;
    IsValidDestination : BOOL;
    IsErrorCondition : BOOL;
END_VAR

(* Initialize variables on first execution *)
IF CurrentState = 0 AND PreviousState = 0 THEN
    CurrentState := 0;
    ParcelSizeThreshold := 50.0;
END_IF;

(* Determine parcel characteristics based on inputs *)
IsLargeParcel := (ParcelSizeSensor >= ParcelSizeThreshold);
IsValidDestination := (DestinationCodeSensor = 1 OR DestinationCodeSensor = 2);
IsErrorCondition := (NOT IsValidDestination);

(* --- STATE MACHINE LOGIC --- *)

(* --- STATE 0: IDLE / ERROR --- *)
IF CurrentState = 0 THEN
    (* Action: Conveyor OFF, Both Gates CLOSED *)
    ConveyorOn := FALSE;
    Gate1On := FALSE;
    Gate2On := FALSE;
    
    (* Transition Logic *)
    IF IsLargeParcel THEN
        CurrentState := 1; (* PROCESS_LARGE *)
    ELSIF IsValidDestination THEN
        IF DestinationCodeSensor = 1 THEN
            CurrentState := 2; (* PROCESS_SMALL_DEST_A *)
        ELSIF DestinationCodeSensor = 2 THEN
            CurrentState := 3; (* PROCESS_SMALL_DEST_B *)
        END_IF;
    ELSE
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
    
    (* Transition Logic: Exit when parcel passes *)
    IF (NOT IsLargeParcel) OR (ParcelSizeSensor = 0.0) THEN
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
    
    (* Transition Logic: Exit when parcel passes *)
    IF (NOT IsLargeParcel) OR (ParcelSizeSensor = 0.0) THEN
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
    
    (* Transition Logic: Exit when parcel passes *)
    IF (NOT IsLargeParcel) OR (ParcelSizeSensor = 0.0) THEN
        CurrentState := 0;
    END_IF;
    
    PreviousState := CurrentState;
END_IF;

(* --- ASSIGN OUTPUTS TO POU OUTPUTS --- *)
ConveyorBeltMotor := ConveyorOn;
SortingGate1 := Gate1On;
SortingGate2 := Gate2On;

END_FUNCTION_BLOCK
END_ST