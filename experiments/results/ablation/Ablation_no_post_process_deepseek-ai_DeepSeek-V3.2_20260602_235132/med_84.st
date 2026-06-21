(* ======================================================================
   Parcel Sorting System - FUNCTION_BLOCK
   ======================================================================
   Description: Controls a conveyor belt and two sorting gates to route
                parcels based on size and destination code.
   Inputs:  ParcelSizeSensor - REAL value representing parcel size
            DestinationCodeSensor - INT code (1=Location A, 2=Location B)
   Outputs: ConveyorBeltMotor - BOOL motor control (TRUE=On)
            SortingGate1 - BOOL gate control (TRUE=Open)
            SortingGate2 - BOOL gate control (TRUE=Open)
   Sorting Logic:
     - Large parcels (Size ≥ LARGE_SIZE_THRESHOLD) → Sorting Gate 1
     - Small parcels to Location A (Dest=1) → Sorting Gate 2
     - Small parcels to Location B (Dest=2) → No gate activation
     - Invalid inputs → Stop conveyor, close both gates
   ====================================================================== *)

(* ----------------------------------------------------------------------
   Constants and Configuration Parameters
   ---------------------------------------------------------------------- *)
VAR CONSTANT
    LARGE_SIZE_THRESHOLD : REAL := 50.0;  (* Size threshold for large parcels *)
    MIN_VALID_SIZE : REAL := 0.001;       (* Minimum valid parcel size *)
END_VAR

(* ----------------------------------------------------------------------
   Internal Variables for State Management
   ---------------------------------------------------------------------- *)
VAR
    (* State flags *)
    bInputsValid : BOOL;      (* TRUE when both sensor inputs are valid *)
    bIsLargeParcel : BOOL;    (* TRUE when parcel size ≥ threshold *)
    bDestIsA : BOOL;          (* TRUE when destination code = 1 (Location A) *)
    bDestIsB : BOOL;          (* TRUE when destination code = 2 (Location B) *)
    
    (* Intermediate calculation variables *)
    rParcelSize : REAL;       (* Local copy of size input *)
    iDestCode : INT;          (* Local copy of destination input *)
END_VAR

(* ======================================================================
   FUNCTION_BODY: Main Control Logic
   ====================================================================== *)

(* ----------------------------------------------------------------------
   STEP 1: Read and Validate Inputs
   ---------------------------------------------------------------------- *)
(* Make local copies of inputs for processing *)
rParcelSize := ParcelSizeSensor;
iDestCode := DestinationCodeSensor;

(* Validate parcel size: must be positive and above minimum threshold *)
IF rParcelSize >= MIN_VALID_SIZE THEN
    (* Validate destination code: must be 1 or 2 *)
    IF (iDestCode = 1) OR (iDestCode = 2) THEN
        bInputsValid := TRUE;
    ELSE
        bInputsValid := FALSE;
    END_IF;
ELSE
    bInputsValid := FALSE;
END_IF;

(* ----------------------------------------------------------------------
   STEP 2: Process Valid Inputs - Determine Parcel Characteristics
   ---------------------------------------------------------------------- *)
IF bInputsValid THEN
    (* Determine if parcel is large based on threshold *)
    IF rParcelSize >= LARGE_SIZE_THRESHOLD THEN
        bIsLargeParcel := TRUE;
    ELSE
        bIsLargeParcel := FALSE;
    END_IF;
    
    (* Determine destination *)
    bDestIsA := (iDestCode = 1);
    bDestIsB := (iDestCode = 2);
    
    (* ------------------------------------------------------------------
       STEP 3: Apply Sorting Rules (Decision Matrix)
       ------------------------------------------------------------------ *)
    
    (* Rule 1: Conveyor runs for all valid inputs *)
    ConveyorBeltMotor := TRUE;
    
    (* Rule 2: Large parcels go to Gate 1 (regardless of destination) *)
    IF bIsLargeParcel THEN
        SortingGate1 := TRUE;
        SortingGate2 := FALSE;
    (* Rule 3: Small parcels to Location A go to Gate 2 *)
    ELSIF bDestIsA THEN
        SortingGate1 := FALSE;
        SortingGate2 := TRUE;
    (* Rule 4: Small parcels to Location B - no gate activation *)
    ELSIF bDestIsB THEN
        SortingGate1 := FALSE;
        SortingGate2 := FALSE;
    (* Fallback: Should not occur if inputs are valid, but for safety *)
    ELSE
        SortingGate1 := FALSE;
        SortingGate2 := FALSE;
    END_IF;
    
(* ----------------------------------------------------------------------
   STEP 4: Handle Invalid Inputs - Error State
   ---------------------------------------------------------------------- *)
ELSE
    (* Invalid inputs: Stop conveyor and close both gates *)
    ConveyorBeltMotor := FALSE;
    SortingGate1 := FALSE;
    SortingGate2 := FALSE;
    
    (* Reset internal state variables for safety *)
    bIsLargeParcel := FALSE;
    bDestIsA := FALSE;
    bDestIsB := FALSE;
END_IF;

(* ======================================================================
   END OF FUNCTION_BODY
   ====================================================================== *)