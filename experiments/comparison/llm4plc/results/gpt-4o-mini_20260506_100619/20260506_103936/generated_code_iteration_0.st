ructured-text
FUNCTION_BLOCK FruitJuicingBottling
VAR_INPUT
    StartButton : BOOL; (* Input for starting the process *)
    StopButton : BOOL;  (* Input for stopping the process *)
    FruitSelected : BOOL; (* Input indicating fruit selection *)
END_VAR
VAR_OUTPUT
    JuiceProcessing : BOOL; (* Output for controlling juice extraction *)
    BottleFilling : BOOL;   (* Output for controlling bottle filling *)
    CapPlacement : BOOL;     (* Output for placing caps on bottles *)
    Packaging : BOOL;        (* Output for packaging filled bottles *)
    ProcessInProgress : BOOL; (* Indicator for an ongoing process *)
END_VAR
VAR
    state : INT;           (* The state variable (0 for INITIALIZE, 1 for PROCESSING) *)
    prevState : INT;      (* The previous state variable *)
END_VAR

(* Initialize state machine *)
state := 0; (* Set initial state to 0 (INITIALIZE) *)
JuiceProcessing := FALSE; 
BottleFilling := FALSE; 
CapPlacement := FALSE; 
Packaging := FALSE; 
ProcessInProgress := FALSE;

(* State machine logic *)
IF state = 0 THEN
    (* Check transition conditions to move to state 1 (PROCESSING) *)
    IF StartButton = TRUE AND FruitSelected = TRUE AND ProcessInProgress = FALSE THEN
        state := 1; (* Transition to PROCESSING state *)
    END_IF
ELSIF state = 1 THEN
    (* Check transition conditions to move back to state 0 (INITIALIZE) *)
    IF StopButton = TRUE OR FruitSelected = FALSE THEN
        state := 0; (* Transition to INITIALIZE state *)
    END_IF
END_IF

(* Output assignments based on the current state *)
CASE state OF
    0: (* INITIALIZE state *)
        JuiceProcessing := FALSE; 
        BottleFilling := FALSE; 
        CapPlacement := FALSE; 
        Packaging := FALSE; 
        ProcessInProgress := FALSE;
    1: (* PROCESSING state *)
        JuiceProcessing := TRUE; 
        BottleFilling := TRUE; 
        CapPlacement := TRUE; 
        Packaging := TRUE; 
        ProcessInProgress := TRUE;
END_CASE

END_FUNCTION_BLOCK