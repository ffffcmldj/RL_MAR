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
    bProcessRunning : BOOL;     (* Internal process state *)
    rTrigStart : R_TRIG;        (* Rising edge detection for StartButton *)
END_VAR

(* Rising edge detection for StartButton *)
rTrigStart(CLK := StartButton);

(* Process start/stop logic *)
IF rTrigStart.Q AND FruitSelected AND NOT bProcessRunning THEN
    bProcessRunning := TRUE;
END_IF;

IF StopButton OR NOT FruitSelected THEN
    bProcessRunning := FALSE;
END_IF;

(* Set outputs based on process state *)
ProcessInProgress := bProcessRunning;
JuiceProcessing := bProcessRunning;
BottleFilling := bProcessRunning;
CapPlacement := bProcessRunning;
Packaging := bProcessRunning;

END_FUNCTION_BLOCK