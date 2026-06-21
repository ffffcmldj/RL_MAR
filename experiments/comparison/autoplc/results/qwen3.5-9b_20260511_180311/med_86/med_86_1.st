FUNCTION_BLOCK FruitJuicingBottling
VAR_INPUT
    StartButton : BOOL;
    StopButton : BOOL;
    FruitSelected : BOOL;
END_VAR
VAR_OUTPUT
    JuiceProcessing : BOOL;
    BottleFilling : BOOL;
    CapPlacement : BOOL;
    Packaging : BOOL;
    ProcessInProgress : BOOL;
END_VAR
VAR
    PreviousProcessInProgress : BOOL;
END_VAR

PreviousProcessInProgress := ProcessInProgress;

IF StopButton = TRUE THEN
    ProcessInProgress := FALSE;
    JuiceProcessing := FALSE;
    BottleFilling := FALSE;
    CapPlacement := FALSE;
    Packaging := FALSE;
ELSIF FruitSelected = FALSE THEN
    ProcessInProgress := FALSE;
    JuiceProcessing := FALSE;
    BottleFilling := FALSE;
    CapPlacement := FALSE;
    Packaging := FALSE;
ELSE
    IF PreviousProcessInProgress = FALSE AND StartButton = TRUE THEN
        ProcessInProgress := TRUE;
        JuiceProcessing := TRUE;
        BottleFilling := TRUE;
        CapPlacement := TRUE;
        Packaging := TRUE;
    ELSIF ProcessInProgress = TRUE THEN
        ProcessInProgress := TRUE;
        JuiceProcessing := TRUE;
        BottleFilling := TRUE;
        CapPlacement := TRUE;
        Packaging := TRUE;
    ELSE
        ProcessInProgress := FALSE;
        JuiceProcessing := FALSE;
        BottleFilling := FALSE;
        CapPlacement := FALSE;
        Packaging := FALSE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK