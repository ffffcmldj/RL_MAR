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
    StartConditionMet : BOOL; (* Internal flag to check start conditions *)
    StopConditionMet : BOOL; (* Internal flag to check stop conditions *)
END_VAR

(* Initialization *)
JuiceProcessing := FALSE;
BottleFilling := FALSE;
CapPlacement := FALSE;
Packaging := FALSE;
ProcessInProgress := FALSE;

(* Start/Stop Control Logic *)
StartConditionMet := StartButton AND FruitSelected AND NOT ProcessInProgress;
StopConditionMet := StopButton OR NOT FruitSelected;

IF StartConditionMet THEN
    (* Transition to Active State *)
    ProcessInProgress := TRUE;
    JuiceProcessing := TRUE;
    BottleFilling := TRUE;
    CapPlacement := TRUE;
    Packaging := TRUE;
ELSIF StopConditionMet THEN
    (* Transition to Idle State *)
    ProcessInProgress := FALSE;
    JuiceProcessing := FALSE;
    BottleFilling := FALSE;
    CapPlacement := FALSE;
    Packaging := FALSE;
END_IF

END_FUNCTION_BLOCK