FUNCTION_BLOCK DocumentFilingSystem
VAR_INPUT
    DocumentInlet : BOOL;
    CategorySelector : INT;
END_VAR
VAR_OUTPUT
    ConveyorMotor : BOOL;
    StorageBin1 : BOOL;
    StorageBin2 : BOOL;
    StorageBin3 : BOOL;
    StorageBin4 : BOOL;
END_VAR
VAR
    IsValidCategory : BOOL;
    i : INT;
END_VAR

IsValidCategory := (CategorySelector >= 1) AND (CategorySelector <= 4);

IF DocumentInlet = TRUE AND IsValidCategory = TRUE THEN
    ConveyorMotor := TRUE;
    StorageBin1 := FALSE;
    StorageBin2 := FALSE;
    StorageBin3 := FALSE;
    StorageBin4 := FALSE;
    
    FOR i := 1 TO 4 DO
        CASE i OF
            1 : StorageBin1 := TRUE;
            2 : StorageBin2 := TRUE;
            3 : StorageBin3 := TRUE;
            4 : StorageBin4 := TRUE;
        END_CASE;
    END_FOR;
ELSE
    ConveyorMotor := FALSE;
    StorageBin1 := FALSE;
    StorageBin2 := FALSE;
    StorageBin3 := FALSE;
    StorageBin4 := FALSE;
END_IF;

END_FUNCTION_BLOCK