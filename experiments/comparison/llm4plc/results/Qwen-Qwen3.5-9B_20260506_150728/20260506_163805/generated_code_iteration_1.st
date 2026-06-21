START_REASON
The validation feedback indicates a specific syntax error from the CODESYS compiler: "应该用';' 替换'ConveyorMotor'" (Should replace 'ConveyorMotor' with ';').

In IEC 61131-3 Structured Text (ST), variable declarations within the `VAR_INPUT`, `VAR_OUTPUT`, and `VAR` sections must be terminated with a semicolon (`;`). The original code omitted these semicolons after the variable names (e.g., `DocumentInlet : BOOL` instead of `DocumentInlet : BOOL;`). This causes the compiler to fail when it expects the end of the declaration statement.

To fix this, I will add a semicolon after every variable declaration in the `VAR_INPUT`, `VAR_OUTPUT`, and `VAR` sections.
END_REASON

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
    categoryValid : BOOL;
END_VAR

BEGIN
    (* --- STATE 0: IDLE (No document or invalid category) --- *)
    (* Default outputs for IDLE state *)
    ConveyorMotor := FALSE;
    StorageBin1 := FALSE;
    StorageBin2 := FALSE;
    StorageBin3 := FALSE;
    StorageBin4 := FALSE;

    (* --- STATE 1: PROCESSING (Document detected, valid category selected) --- *)
    (* Logic to set outputs based on valid category *)
    IF state = 1 THEN
        ConveyorMotor := TRUE;
        IF CategorySelector = 1 THEN
            StorageBin1 := TRUE;
            StorageBin2 := FALSE;
            StorageBin3 := FALSE;
            StorageBin4 := FALSE;
        ELSIF CategorySelector = 2 THEN
            StorageBin1 := FALSE;
            StorageBin2 := TRUE;
            StorageBin3 := FALSE;
            StorageBin4 := FALSE;
        ELSIF CategorySelector = 3 THEN
            StorageBin1 := FALSE;
            StorageBin2 := FALSE;
            StorageBin3 := TRUE;
            StorageBin4 := FALSE;
        ELSIF CategorySelector = 4 THEN
            StorageBin1 := FALSE;
            StorageBin2 := FALSE;
            StorageBin3 := FALSE;
            StorageBin4 := TRUE;
        END_IF;
    END_IF;

    (* --- STATE MANAGEMENT --- *)
    (* Determine if category is valid (1 to 4) *)
    categoryValid := (CategorySelector >= 1) AND (CategorySelector <= 4);

    (* Transition Logic *)
    (* STATE 0 -> STATE 1: IF (DocumentInlet = TRUE) AND (Category is Valid) *)
    (* STATE 1 -> STATE 0: IF (DocumentInlet = FALSE) OR (Category is Invalid) *)

    IF state = 0 THEN
        (* Check transition condition from IDLE to PROCESSING *)
        IF (DocumentInlet = TRUE) AND categoryValid THEN
            state := 1;
        END_IF;
    ELSE
        (* state = 1 (PROCESSING) *)
        (* Check transition condition from PROCESSING to IDLE *)
        IF (DocumentInlet = FALSE) OR (NOT categoryValid) THEN
            state := 0;
        END_IF;
    END_IF;

END_FUNCTION_BLOCK
END_ST