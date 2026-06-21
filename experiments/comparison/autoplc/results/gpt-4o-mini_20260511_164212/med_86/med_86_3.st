FUNCTION_BLOCK FruitJuicingBottling
VAR_INPUT
    StartButton : BOOL; (* Input for starting the process *)
    StopButton : BOOL;  (* Input for stopping the process *)
    FruitSelected : BOOL; (* Input indicating fruit selection *)
END_VAR

VAR_OUTPUT
    JuiceProcessing : BOOL; (* Output for controlling juice extraction *)
    BottleFilling : BOOL;   (* Output for controlling bottle filling *)
    CapPlacement : BOOL;     (* Output for placing caps on bottles *)
    Packaging : BOOL;        (* Output for packaging filled bottles *)
    ProcessInProgress : BOOL; (* Indicator for an ongoing process *)
END_VAR

VAR
    State : INT; (* State variable to track the current state of the process *)
END_VAR

(* State Definitions *)
CONST
    IDLE : INT := 0;
    RUNNING : INT := 1;
    STOPPED : INT := 2;
END_CONST

(* Initialization Logic *)
JuiceProcessing := FALSE;
BottleFilling := FALSE;
CapPlacement := FALSE;
Packaging := FALSE;
ProcessInProgress := FALSE;
State := IDLE;

(* State Management Logic *)
IF State = IDLE THEN
    IF StartButton AND FruitSelected AND NOT ProcessInProgress THEN
        State := RUNNING;
        ProcessInProgress := TRUE;
        JuiceProcessing := TRUE;
        BottleFilling := TRUE;
        CapPlacement := TRUE;
        Packaging := TRUE;
    END_IF
ELSIF State = RUNNING THEN
    IF StopButton OR NOT FruitSelected THEN
        State := STOPPED;
        ProcessInProgress := FALSE;
        JuiceProcessing := FALSE;
        BottleFilling := FALSE;
        CapPlacement := FALSE;
        Packaging := FALSE;
    END_IF
ELSIF State = STOPPED THEN
    IF StartButton AND FruitSelected AND NOT ProcessInProgress THEN
        State := RUNNING;
        ProcessInProgress := TRUE;
        JuiceProcessing := TRUE;
        BottleFilling := TRUE;
        CapPlacement := TRUE;
        Packaging := TRUE;
    END_IF
END_IF

END_FUNCTION_BLOCK