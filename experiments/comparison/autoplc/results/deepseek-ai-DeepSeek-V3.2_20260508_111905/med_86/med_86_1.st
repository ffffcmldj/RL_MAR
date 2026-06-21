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
    bStartRisingEdgeDetected : BOOL; (* Internal flag for start button rising edge detection *)
    bPrevStartButton : BOOL; (* Previous state of start button for edge detection *)
    bInternalProcessActive : BOOL; (* Internal state tracking *)
END_VAR

(* Initialize internal variables on first scan *)
IF NOT bPrevStartButton THEN
    bPrevStartButton := FALSE;
    bStartRisingEdgeDetected := FALSE;
    bInternalProcessActive := FALSE;
END_IF

(* Rising edge detection for StartButton *)
bStartRisingEdgeDetected := StartButton AND NOT bPrevStartButton;
bPrevStartButton := StartButton;

(* State transition logic - Idle to Active *)
IF NOT bInternalProcessActive THEN
    (* Check start conditions: rising edge of StartButton, FruitSelected TRUE, and process not already in progress *)
    IF bStartRisingEdgeDetected AND FruitSelected AND NOT bInternalProcessActive THEN
        bInternalProcessActive := TRUE;
    END_IF
END_IF

(* State transition logic - Active to Idle *)
IF bInternalProcessActive THEN
    (* Check stop conditions: StopButton pressed OR FruitSelected becomes FALSE *)
    IF StopButton OR NOT FruitSelected THEN
        bInternalProcessActive := FALSE;
    END_IF
END_IF

(* Set outputs based on internal state *)
ProcessInProgress := bInternalProcessActive;

(* All process stages are active concurrently when process is in progress *)
JuiceProcessing := bInternalProcessActive;
BottleFilling := bInternalProcessActive;
CapPlacement := bInternalProcessActive;
Packaging := bInternalProcessActive;

END_FUNCTION_BLOCK