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
        StartRisingEdge : BOOL;
        PrevStartButton : BOOL;
    END_VAR

    (* Rising edge detection for StartButton *)
    StartRisingEdge := StartButton AND NOT PrevStartButton;
    PrevStartButton := StartButton;

    (* Process state control *)
    IF StartRisingEdge AND FruitSelected AND NOT ProcessInProgress THEN
        ProcessInProgress := TRUE;
    END_IF;

    IF StopButton OR NOT FruitSelected THEN
        ProcessInProgress := FALSE;
    END_IF;

    (* Concurrent stage outputs *)
    JuiceProcessing := ProcessInProgress;
    BottleFilling := ProcessInProgress;
    CapPlacement := ProcessInProgress;
    Packaging := ProcessInProgress;
END_FUNCTION_BLOCK;