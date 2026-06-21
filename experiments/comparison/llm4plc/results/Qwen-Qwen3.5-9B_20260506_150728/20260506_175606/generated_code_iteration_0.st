START_ST
FUNCTION_BLOCK FruitJuicingBottling
VAR_INPUT
    StartButton : BOOL; (* Input for starting the process *)
    StopButton : BOOL; (* Input for stopping the process *)
    FruitSelected : BOOL; (* Input indicating fruit selection *)
END_VAR
VAR_OUTPUT
    JuiceProcessing : BOOL; (* Output for controlling juice extraction *)
    BottleFilling : BOOL; (* Output for controlling bottle filling *)
    CapPlacement : BOOL; (* Output for placing caps on bottles *)
    Packaging : BOOL; (* Output for packaging filled bottles *)
    ProcessInProgress : BOOL; (* Indicator for an ongoing process *)
END_VAR
VAR
    state : INT; (* Current FSM State: 0=IDLE, 1=RUNNING, 2=STOPPED *)
    prevState : INT; (* Previous State for transition logic *)
    processInProgress : BOOL; (* Internal variable to track running state *)
END_VAR

(* Initialize state on first execution or reset if needed *)
IF state = 0 AND prevState = 0 THEN
    state := 0;
END_IF;

(* Store current state for next cycle transition logic *)
prevState := state;

(* --- STATE MACHINE LOGIC --- *)

(* Transition from STATE 0 (IDLE) to STATE 1 (RUNNING) *)
(* Condition: StartButton AND FruitSelected AND NOT ProcessInProgress *)
IF state = 0 THEN
    IF StartButton = TRUE AND FruitSelected = TRUE AND ProcessInProgress = FALSE THEN
        state := 1; (* Transition to RUNNING *)
    END_IF;
END_IF;

(* Transition from STATE 1 (RUNNING) to STATE 2 (STOPPED) *)
(* Condition: StopButton OR NOT FruitSelected *)
IF state = 1 THEN
    IF StopButton = TRUE OR FruitSelected = FALSE THEN
        state := 2; (* Transition to STOPPED *)
    END_IF;
END_IF;

(* Transition from STATE 2 (STOPPED) to STATE 0 (IDLE) *)
(* Condition: StopButton is FALSE AND FruitSelected is TRUE *)
IF state = 2 THEN
    IF StopButton = FALSE AND FruitSelected = TRUE THEN
        state := 0; (* Transition back to IDLE *)
    END_IF;
END_IF;

(* --- OUTPUT ASSIGNMENT BASED ON STATE --- *)

(* STATE 0: IDLE *)
IF state = 0 THEN
    JuiceProcessing := FALSE;
    BottleFilling := FALSE;
    CapPlacement := FALSE;
    Packaging := FALSE;
    ProcessInProgress := FALSE;
END_IF;

(* STATE 1: RUNNING *)
IF state = 1 THEN
    JuiceProcessing := TRUE;
    BottleFilling := TRUE;
    CapPlacement := TRUE;
    Packaging := TRUE;
    ProcessInProgress := TRUE;
END_IF;

(* STATE 2: STOPPED *)
IF state = 2 THEN
    JuiceProcessing := FALSE;
    BottleFilling := FALSE;
    CapPlacement := FALSE;
    Packaging := FALSE;
    ProcessInProgress := FALSE;
END_IF;

END_FUNCTION_BLOCK
END_ST