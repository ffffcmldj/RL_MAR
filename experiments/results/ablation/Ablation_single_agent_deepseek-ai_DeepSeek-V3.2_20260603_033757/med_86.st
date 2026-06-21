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
    eState : (IDLE, RUNNING);  (* State variable for process control *)
END_VAR

(* Main process logic *)
CASE eState OF
    IDLE:
        (* Reset all outputs when idle *)
        ProcessInProgress := FALSE;
        JuiceProcessing := FALSE;
        BottleFilling := FALSE;
        CapPlacement := FALSE;
        Packaging := FALSE;
        
        (* Check start conditions: StartButton pressed, fruit selected, and no process running *)
        IF StartButton AND FruitSelected AND NOT ProcessInProgress THEN
            eState := RUNNING;
        END_IF;
        
    RUNNING:
        (* Set process indicator and activate all concurrent stages *)
        ProcessInProgress := TRUE;
        JuiceProcessing := TRUE;
        BottleFilling := TRUE;
        CapPlacement := TRUE;
        Packaging := TRUE;
        
        (* Check stop conditions: StopButton pressed OR fruit deselected *)
        IF StopButton OR NOT FruitSelected THEN
            eState := IDLE;
        END_IF;
END_CASE;
END_FUNCTION_BLOCK