(*
    FUNCTION_BLOCK: DocumentFilingSystem
    DESCRIPTION: Controls an automatic document filing system.
    LOGIC:
        - Conveyor motor runs when a document is detected AND a valid category (1-4) is selected.
        - Only the storage bin corresponding to the selected category is activated.
        - All outputs are deactivated when no document is detected OR an invalid category is selected.
    INPUTS:
        DocumentInlet : BOOL - Signal indicating a document is present at the inlet.
        CategorySelector : INT - Integer code (1-4) selecting the target storage bin.
    OUTPUTS:
        ConveyorMotor : BOOL - Control signal for the conveyor motor.
        StorageBin1 : BOOL - Control signal for storage bin 1 (Category 1).
        StorageBin2 : BOOL - Control signal for storage bin 2 (Category 2).
        StorageBin3 : BOOL - Control signal for storage bin 3 (Category 3).
        StorageBin4 : BOOL - Control signal for storage bin 4 (Category 4).
*)

FUNCTION_BLOCK DocumentFilingSystem
VAR_INPUT
    DocumentInlet : BOOL; (* Input to detect the arrival of a document *)
    CategorySelector : INT; (* Input to select the document category *)
END_VAR
VAR_OUTPUT
    ConveyorMotor : BOOL; (* Output to control the conveyor motor *)
    StorageBin1 : BOOL; (* Output to activate storage bin 1 *)
    StorageBin2 : BOOL; (* Output to activate storage bin 2 *)
    StorageBin3 : BOOL; (* Output to activate storage bin 3 *)
    StorageBin4 : BOOL; (* Output to activate storage bin 4 *)
END_VAR
VAR
    bValidCategory : BOOL; (* Internal flag for category validation *)
END_VAR

    (* 1. Validate the category selector input *)
    bValidCategory := (CategorySelector >= 1) AND (CategorySelector <= 4);

    (* 2. Main Control Logic: Activate outputs only if document is present AND category is valid *)
    IF DocumentInlet AND bValidCategory THEN
        (* Activate the conveyor motor *)
        ConveyorMotor := TRUE;

        (* Activate exactly one storage bin based on the CategorySelector *)
        CASE CategorySelector OF
            1:
                StorageBin1 := TRUE;
                StorageBin2 := FALSE;
                StorageBin3 := FALSE;
                StorageBin4 := FALSE;
            2:
                StorageBin1 := FALSE;
                StorageBin2 := TRUE;
                StorageBin3 := FALSE;
                StorageBin4 := FALSE;
            3:
                StorageBin1 := FALSE;
                StorageBin2 := FALSE;
                StorageBin3 := TRUE;
                StorageBin4 := FALSE;
            4:
                StorageBin1 := FALSE;
                StorageBin2 := FALSE;
                StorageBin3 := FALSE;
                StorageBin4 := TRUE;
            ELSE
                (* This branch is logically unreachable due to the bValidCategory check,
                   but included for robustness and completeness. *)
                StorageBin1 := FALSE;
                StorageBin2 := FALSE;
                StorageBin3 := FALSE;
                StorageBin4 := FALSE;
        END_CASE;
    ELSE
        (* 3. Deactivate all outputs if no document OR invalid category *)
        ConveyorMotor := FALSE;
        StorageBin1 := FALSE;
        StorageBin2 := FALSE;
        StorageBin3 := FALSE;
        StorageBin4 := FALSE;
    END_IF;

END_FUNCTION_BLOCK