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
    i : INT; (* Loop variable for category selection *)
END_VAR

(* Initialization of outputs *)
ConveyorMotor := FALSE;
StorageBin1 := FALSE;
StorageBin2 := FALSE;
StorageBin3 := FALSE;
StorageBin4 := FALSE;

(* State Evaluation *)
IF DocumentInlet THEN
    (* Check for valid category selection *)
    IF (CategorySelector >= 1) AND (CategorySelector <= 4) THEN
        ConveyorMotor := TRUE; (* Activate conveyor motor *)
        
        (* Deactivate all storage bins *)
        StorageBin1 := FALSE;
        StorageBin2 := FALSE;
        StorageBin3 := FALSE;
        StorageBin4 := FALSE;

        (* Activate the corresponding storage bin based on CategorySelector *)
        CASE CategorySelector OF
            1: StorageBin1 := TRUE;
            2: StorageBin2 := TRUE;
            3: StorageBin3 := TRUE;
            4: StorageBin4 := TRUE;
        ELSE
            (* If category is invalid, deactivate all outputs *)
            ConveyorMotor := FALSE;
            StorageBin1 := FALSE;
            StorageBin2 := FALSE;
            StorageBin3 := FALSE;
            StorageBin4 := FALSE;
        END_CASE
    ELSE
        (* If category is invalid, deactivate all outputs *)
        ConveyorMotor := FALSE;
        StorageBin1 := FALSE;
        StorageBin2 := FALSE;
        StorageBin3 := FALSE;
        StorageBin4 := FALSE;
    END_IF
ELSE
    (* If no document is detected, deactivate all outputs *)
    ConveyorMotor := FALSE;
    StorageBin1 := FALSE;
    StorageBin2 := FALSE;
    StorageBin3 := FALSE;
    StorageBin4 := FALSE;
END_IF

END_FUNCTION_BLOCK