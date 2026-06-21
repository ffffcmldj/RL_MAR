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
    state : INT; (* Current state: 0 = IDLE, 1 = PROCESS_RUNNING *)
    prevState : INT; (* Previous state for edge detection *)
    startRisingEdge : BOOL; (* Rising edge detection for StartButton *)
    stopRisingEdge : BOOL; (* Rising edge detection for StopButton *)
    startPrev : BOOL; (* Previous value of StartButton for edge detection *)
    stopPrev : BOOL; (* Previous value of StopButton for edge detection *)
END_VAR

(* Edge detection for StartButton and StopButton *)
startRisingEdge := StartButton AND NOT startPrev;
stopRisingEdge := StopButton AND NOT stopPrev;

(* State machine logic *)
CASE state OF
    0: (* IDLE state *)
        (* Set outputs for IDLE state *)
        JuiceProcessing := FALSE;
        BottleFilling := FALSE;
        CapPlacement := FALSE;
        Packaging := FALSE;
        ProcessInProgress := FALSE;

        (* Transition to PROCESS_RUNNING state *)
        IF startRisingEdge AND FruitSelected AND (NOT ProcessInProgress) THEN
            state := 1;
        END_IF;

    1: (* PROCESS_RUNNING state *)
        (* Set outputs for PROCESS_RUNNING state *)
        JuiceProcessing := TRUE;
        BottleFilling := TRUE;
        CapPlacement := TRUE;
        Packaging := TRUE;
        ProcessInProgress := TRUE;

        (* Transition to IDLE state *)
        IF stopRisingEdge OR (NOT FruitSelected) THEN
            state := 0;
        END_IF;
END_CASE;

(* Update previous values for edge detection *)
startPrev := StartButton;
stopPrev := StopButton;
prevState := state;

END_FUNCTION_BLOCK
END_ST