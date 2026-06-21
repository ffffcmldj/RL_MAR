START_ST
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
    state : INT;
    prevState : INT;
END_VAR

    (* Initialize state to IDLE (0) on first call *)
    IF prevState = 0 THEN
        state := 0;
    END_IF;

    (* State machine logic *)
    CASE state OF
        0: (* IDLE *)
            ConveyorMotor := FALSE;
            StorageBin1 := FALSE;
            StorageBin2 := FALSE;
            StorageBin3 := FALSE;
            StorageBin4 := FALSE;

            IF DocumentInlet AND (CategorySelector = 1) THEN
                state := 1;
            ELSIF DocumentInlet AND (CategorySelector = 2) THEN
                state := 2;
            ELSIF DocumentInlet AND (CategorySelector = 3) THEN
                state := 3;
            ELSIF DocumentInlet AND (CategorySelector = 4) THEN
                state := 4;
            END_IF;

        1: (* PROCESSING_CATEGORY_1 *)
            ConveyorMotor := TRUE;
            StorageBin1 := TRUE;
            StorageBin2 := FALSE;
            StorageBin3 := FALSE;
            StorageBin4 := FALSE;

            IF (NOT DocumentInlet) OR (CategorySelector <> 1) THEN
                state := 0;
            END_IF;

        2: (* PROCESSING_CATEGORY_2 *)
            ConveyorMotor := TRUE;
            StorageBin1 := FALSE;
            StorageBin2 := TRUE;
            StorageBin3 := FALSE;
            StorageBin4 := FALSE;

            IF (NOT DocumentInlet) OR (CategorySelector <> 2) THEN
                state := 0;
            END_IF;

        3: (* PROCESSING_CATEGORY_3 *)
            ConveyorMotor := TRUE;
            StorageBin1 := FALSE;
            StorageBin2 := FALSE;
            StorageBin3 := TRUE;
            StorageBin4 := FALSE;

            IF (NOT DocumentInlet) OR (CategorySelector <> 3) THEN
                state := 0;
            END_IF;

        4: (* PROCESSING_CATEGORY_4 *)
            ConveyorMotor := TRUE;
            StorageBin1 := FALSE;
            StorageBin2 := FALSE;
            StorageBin3 := FALSE;
            StorageBin4 := TRUE;

            IF (NOT DocumentInlet) OR (CategorySelector <> 4) THEN
                state := 0;
            END_IF;

        ELSE
            (* Fallback to IDLE state *)
            state := 0;
            ConveyorMotor := FALSE;
            StorageBin1 := FALSE;
            StorageBin2 := FALSE;
            StorageBin3 := FALSE;
            StorageBin4 := FALSE;
    END_CASE;

    (* Update previous state for initialization check *)
    prevState := state;

END_FUNCTION_BLOCK
END_ST