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
    state : INT := 0; (* Current state of the system, initialized to STATE 0 (IDLE) *)
    prevState : INT := -1; (* Previous state of the system, initialized to an invalid state *)
END_VAR

(* State Definitions *)
CONST
    STATE_IDLE : INT := 0; (* System is idle *)
    STATE_PROCESS_RUNNING : INT := 1; (* System is running the process *)
    STATE_STOPPING : INT := 2; (* System is stopping *)
END_VAR

(* Main Logic *)
CASE state OF
    (* STATE 0: IDLE *)
    STATE_IDLE:
        (* Set outputs to FALSE *)
        JuiceProcessing := FALSE;
        BottleFilling := FALSE;
        CapPlacement := FALSE;
        Packaging := FALSE;
        ProcessInProgress := FALSE;

        (* Transition to STATE 1 if start conditions are met *)
        IF StartButton AND FruitSelected AND NOT ProcessInProgress THEN
            prevState := state; (* Store the current state as the previous state *)
            state := STATE_PROCESS_RUNNING; (* Transition to STATE 1 *)
        END_IF;

    (* STATE 1: PROCESS_RUNNING *)
    STATE_PROCESS_RUNNING:
        (* Set outputs to TRUE *)
        JuiceProcessing := TRUE;
        BottleFilling := TRUE;
        CapPlacement := TRUE;
        Packaging := TRUE;
        ProcessInProgress := TRUE;

        (* Transition to STATE 2 if stop conditions are met *)
        IF StopButton OR NOT FruitSelected THEN
            prevState := state; (* Store the current state as the previous state *)
            state := STATE_STOPPING; (* Transition to STATE 2 *)
        END_IF;

    (* STATE 2: STOPPING *)
    STATE_STOPPING:
        (* Set outputs to FALSE *)
        JuiceProcessing := FALSE;
        BottleFilling := FALSE;
        CapPlacement := FALSE;
        Packaging := FALSE;
        ProcessInProgress := FALSE;

        (* Transition back to STATE 0 once stopping is complete *)
        prevState := state; (* Store the current state as the previous state *)
        state := STATE_IDLE; (* Transition to STATE 0 *)

    ELSE
        (* Default case to handle unexpected states *)
        state := STATE_IDLE; (* Reset to STATE 0 *)
END_CASE;

END_FUNCTION_BLOCK
END_ST