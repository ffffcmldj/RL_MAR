FUNCTION_BLOCK FruitJuicingBottling
VAR_INPUT
    StartButton : BOOL;        (* Input for starting the process *)
    StopButton : BOOL;         (* Input for stopping the process *)
    FruitSelected : BOOL;      (* Input indicating fruit selection *)
END_VAR
VAR_OUTPUT
    JuiceProcessing : BOOL;    (* Output for controlling juice extraction *)
    BottleFilling : BOOL;      (* Output for controlling bottle filling *)
    CapPlacement : BOOL;       (* Output for placing caps on bottles *)
    Packaging : BOOL;          (* Output for packaging filled bottles *)
    ProcessInProgress : BOOL;  (* Indicator for an ongoing process *)
END_VAR
VAR
    bProcessActive : BOOL;     (* Internal process state *)
END_VAR

(* Start condition: StartButton pressed, fruit selected, and no process running *)
IF StartButton AND FruitSelected AND NOT ProcessInProgress THEN
    bProcessActive := TRUE;
END_IF;

(* Stop condition: StopButton pressed OR fruit deselected during operation *)
IF StopButton OR NOT FruitSelected THEN
    bProcessActive := FALSE;
END_IF;

(* Process tracking output *)
ProcessInProgress := bProcessActive;

(* Concurrent process stages - all active when process is running *)
JuiceProcessing := ProcessInProgress;
BottleFilling := ProcessInProgress;
CapPlacement := ProcessInProgress;
Packaging := ProcessInProgress;

END_FUNCTION_BLOCK