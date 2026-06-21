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
    ValidCategory : BOOL; (* Internal flag for valid category range *)
END_VAR

(* Check if category selector is within valid range (1-4) *)
ValidCategory := (CategorySelector >= 1) AND (CategorySelector <= 4);

(* Main control logic *)
IF DocumentInlet AND ValidCategory THEN
    (* Activate conveyor motor when document is present and category is valid *)
    ConveyorMotor := TRUE;
    
    (* Activate only the selected storage bin based on category *)
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
            (* This should never happen since ValidCategory is checked, but included for safety *)
            StorageBin1 := FALSE;
            StorageBin2 := FALSE;
            StorageBin3 := FALSE;
            StorageBin4 := FALSE;
    END_CASE;
ELSE
    (* Deactivate all outputs when no document or invalid category *)
    ConveyorMotor := FALSE;
    StorageBin1 := FALSE;
    StorageBin2 := FALSE;
    StorageBin3 := FALSE;
    StorageBin4 := FALSE;
END_IF;

END_FUNCTION_BLOCK