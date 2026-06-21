FUNCTION_BLOCK FruitJuicingBottling
VAR_INPUT
    StartButton : BOOL;     (* Input for starting the process *)
    StopButton : BOOL;      (* Input for stopping the process *)
    FruitSelected : BOOL;   (* Input indicating fruit selection *)
END_VAR
VAR_OUTPUT
    JuiceProcessing : BOOL;     (* Output for controlling juice extraction *)
    BottleFilling : BOOL;       (* Output for controlling bottle filling *)
    CapPlacement : BOOL;        (* Output for placing caps on bottles *)
    Packaging : BOOL;           (* Output for packaging filled bottles *)
    ProcessInProgress : BOOL;   (* Indicator for an ongoing process *)
END_VAR
VAR
    bStartRisingEdge : BOOL;    (* Edge detection for StartButton *)
    bPrevStartButton : BOOL;    (* Previous state of StartButton *)
END_VAR

(* Edge detection for StartButton *)
bStartRisingEdge := StartButton AND NOT bPrevStartButton;
bPrevStartButton := StartButton;

(* Main process control logic *)
IF (bStartRisingEdge AND FruitSelected AND NOT ProcessInProgress) THEN
    ProcessInProgress := TRUE;
END_IF;

IF (StopButton OR NOT FruitSelected) THEN
    ProcessInProgress := FALSE;
END_IF;

(* Concurrent process stage outputs *)
JuiceProcessing := ProcessInProgress;
BottleFilling := ProcessInProgress;
CapPlacement := ProcessInProgress;
Packaging := ProcessInProgress;

END_FUNCTION_BLOCK