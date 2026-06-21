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
    isValidCategory : BOOL; (* Internal variable to check if the category is valid *)
END_VAR

(* Initialization: Set all outputs to FALSE *)
ConveyorMotor := FALSE;
StorageBin1 := FALSE;
StorageBin2 := FALSE;
StorageBin3 := FALSE;
StorageBin4 := FALSE;

(* Check if the category is valid (1 to 4) *)
isValidCategory := (CategorySelector >= 1) AND (CategorySelector <= 4);

(* Control Logic *)
IF DocumentInlet AND isValidCategory THEN
    (* Activate the conveyor motor *)
    ConveyorMotor := TRUE;
    
    (* Activate the corresponding storage bin based on the category *)
    CASE CategorySelector OF
        1: 
            StorageBin1 := TRUE;
        2: 
            StorageBin2 := TRUE;
        3: 
            StorageBin3 := TRUE;
        4: 
            StorageBin4 := TRUE;
    END_CASE;
ELSE
    (* Deactivate all outputs if no document is detected or category is invalid *)
    ConveyorMotor := FALSE;
    StorageBin1 := FALSE;
    StorageBin2 := FALSE;
    StorageBin3 := FALSE;
    StorageBin4 := FALSE;
END_IF;

END_FUNCTION_BLOCK