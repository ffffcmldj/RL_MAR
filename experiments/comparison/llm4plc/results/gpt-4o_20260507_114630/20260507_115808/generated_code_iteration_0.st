pascal
START_ST
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
    state : INT; (* The current state of the system *)
    prevState : INT; (* The previous state of the system *)
END_VAR

(* Initialize state to IDLE (STATE 0) *)
IF NOT DocumentInlet THEN
    state := 0; (* IDLE state *)
ELSIF DocumentInlet THEN
    state := 1; (* Processing state *)
END_IF

(* State transition logic *)
CASE state OF
    0: (* IDLE state *)
        ConveyorMotor := FALSE;
        StorageBin1 := FALSE;
        StorageBin2 := FALSE;
        StorageBin3 := FALSE;
        StorageBin4 := FALSE;
    1: (* Processing state *)
        ConveyorMotor := TRUE;
        StorageBin1 := TRUE;
        StorageBin2 := TRUE;
        StorageBin3 := TRUE;
        StorageBin4 := TRUE;
END_CASE
END_ST