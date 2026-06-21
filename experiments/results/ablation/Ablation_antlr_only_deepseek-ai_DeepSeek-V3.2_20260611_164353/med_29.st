(*
    FUNCTION_BLOCK: DocumentFilingSystem
    DESCRIPTION: Controls an automatic document filing system with a conveyor and four storage bins.
    LOGIC:
        - Conveyor motor runs when a document is present AND a valid category (1-4) is selected.
        - Only the storage bin corresponding to the selected category is activated.
        - All outputs are deactivated when no document is present OR an invalid category is selected.
    AUTHOR: Senior PLC Commissioning Engineer
    VERSION: 1.0
    COMPLIANCE: IEC 61131-3
*)

FUNCTION_BLOCK DocumentFilingSystem
VAR_INPUT
    DocumentInlet : BOOL; (* TRUE when a document is detected at the inlet *)
    CategorySelector : INT; (* Selected document category (1-4) *)
END_VAR
VAR_OUTPUT
    ConveyorMotor : BOOL; (* TRUE to run the conveyor motor *)
    StorageBin1 : BOOL; (* TRUE to activate storage bin 1 *)
    StorageBin2 : BOOL; (* TRUE to activate storage bin 2 *)
    StorageBin3 : BOOL; (* TRUE to activate storage bin 3 *)
    StorageBin4 : BOOL; (* TRUE to activate storage bin 4 *)
END_VAR
VAR
    ValidCategory : BOOL; (* Internal flag for category validation *)
END_VAR

    (* Validate the category selector input *)
    ValidCategory := (CategorySelector >= 1) AND (CategorySelector <= 4);

    (* Main control logic: Process document if present and category is valid *)
    IF DocumentInlet AND ValidCategory THEN
        ConveyorMotor := TRUE; (* Run the conveyor *)

        (* Activate only the selected storage bin *)
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
                (* This ELSE case is a safety fallback, though ValidCategory should prevent it *)
                StorageBin1 := FALSE;
                StorageBin2 := FALSE;
                StorageBin3 := FALSE;
                StorageBin4 := FALSE;
        END_CASE;
    ELSE
        (* No document or invalid category: Deactivate all outputs *)
        ConveyorMotor := FALSE;
        StorageBin1 := FALSE;
        StorageBin2 := FALSE;
        StorageBin3 := FALSE;
        StorageBin4 := FALSE;
    END_IF;

END_FUNCTION_BLOCK