(* ============================================================================
   FUNCTION_BLOCK: ParcelSortingSystem
   Description: Implements control logic for a parcel sorting system.
                Routes parcels based on size and destination code.
   Inputs:  ParcelSizeSensor (REAL), DestinationCodeSensor (INT)
   Outputs: ConveyorBeltMotor (BOOL), SortingGate1 (BOOL), SortingGate2 (BOOL)
   Safety: Invalid inputs stop the conveyor and close all gates.
   Author: Senior PLC Commissioning Engineer
   Standard: IEC 61131-3
   ============================================================================ *)

FUNCTION_BLOCK ParcelSortingSystem
VAR_INPUT
    ParcelSizeSensor : REAL;     (* Measured parcel size [units] *)
    DestinationCodeSensor : INT; (* Destination code: 1=Location A, 2=Location B *)
END_VAR

VAR_OUTPUT
    ConveyorBeltMotor : BOOL; (* TRUE = Motor ON / Conveyor moving *)
    SortingGate1      : BOOL; (* TRUE = Gate 1 OPEN (for large parcels) *)
    SortingGate2      : BOOL; (* TRUE = Gate 2 OPEN (for small to Location A) *)
END_VAR

VAR
    (* Internal Constants *)
    SizeThreshold : REAL := 50.0;   (* Threshold to distinguish large vs. small parcels *)
    MinValidSize  : REAL := 0.01;   (* Minimum valid size to reject zero/negative values *)
    MaxValidSize  : REAL := 1000.0; (* Maximum valid size for sensor range *)
    DestCodeA     : INT := 1;       (* Destination code for Location A *)
    DestCodeB     : INT := 2;       (* Destination code for Location B *)

    (* Internal Flags *)
    bSizeValid    : BOOL; (* TRUE if ParcelSizeSensor is within valid range *)
    bDestValid    : BOOL; (* TRUE if DestinationCodeSensor is 1 or 2 *)
    bInputsValid  : BOOL; (* TRUE if both size and destination are valid *)
END_VAR

(* ============================================================================
   Main Logic Body
   ============================================================================ *)
    (* 1. Input Validation *)
    bSizeValid := (ParcelSizeSensor >= MinValidSize) AND (ParcelSizeSensor <= MaxValidSize);
    bDestValid := (DestinationCodeSensor = DestCodeA) OR (DestinationCodeSensor = DestCodeB);
    bInputsValid := bSizeValid AND bDestValid;

    (* 2. Core Sorting Logic *)
    IF bInputsValid THEN
        (* Valid inputs detected - activate conveyor *)
        ConveyorBeltMotor := TRUE;

        (* Determine parcel routing based on size and destination *)
        IF ParcelSizeSensor > SizeThreshold THEN
            (* LARGE PARCEL: Route to Gate 1, regardless of destination *)
            SortingGate1 := TRUE;
            SortingGate2 := FALSE;
        ELSE
            (* SMALL PARCEL: Route based on destination code *)
            SortingGate1 := FALSE; (* Gate 1 always closed for small parcels *)

            CASE DestinationCodeSensor OF
                DestCodeA:
                    (* Small parcel to Location A: Route to Gate 2 *)
                    SortingGate2 := TRUE;
                DestCodeB:
                    (* Small parcel to Location B: No diversion, keep on main belt *)
                    SortingGate2 := FALSE;
                ELSE
                    (* This case should not occur due to prior validation,
                       but set safe default. *)
                    SortingGate2 := FALSE;
            END_CASE;
        END_IF;
    ELSE
        (* INVALID INPUTS: Safe shutdown state *)
        ConveyorBeltMotor := FALSE;
        SortingGate1      := FALSE;
        SortingGate2      := FALSE;
    END_IF;

END_FUNCTION_BLOCK;