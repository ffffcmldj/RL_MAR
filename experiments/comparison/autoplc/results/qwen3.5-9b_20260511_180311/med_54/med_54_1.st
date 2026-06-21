FUNCTION_BLOCK FeedForwardControl
VAR_INPUT
    FlowRate1, FlowRate2: REAL;
    MixRatio: REAL;
END_VAR
VAR_OUTPUT
    OutFlowRate1, OutFlowRate2: REAL;
END_VAR
VAR
    MixedFlowRate: REAL;
    TempFlowRate1: REAL;
    TempFlowRate2: REAL;
    Denominator: REAL;
END_VAR

TempFlowRate1 := FlowRate1;
IF TempFlowRate1 < 0.0 THEN
    TempFlowRate1 := 0.0;
ELSIF TempFlowRate1 > 100.0 THEN
    TempFlowRate1 := 100.0;
END_IF;

TempFlowRate2 := FlowRate2;
IF TempFlowRate2 < 0.0 THEN
    TempFlowRate2 := 0.0;
ELSIF TempFlowRate2 > 100.0 THEN
    TempFlowRate2 := 100.0;
END_IF;

MixedFlowRate := TempFlowRate1 + TempFlowRate2;

IF MixedFlowRate = 0.0 THEN
    OutFlowRate1 := 0.0;
    OutFlowRate2 := 0.0;
ELSE
    Denominator := MixRatio + 1.0;
    IF Denominator = 0.0 THEN
        OutFlowRate1 := 0.0;
        OutFlowRate2 := 0.0;
    ELSE
        OutFlowRate1 := (MixRatio / Denominator) * MixedFlowRate;
        OutFlowRate2 := (1.0 / Denominator) * MixedFlowRate;
        
        IF OutFlowRate1 < 0.0 THEN
            OutFlowRate1 := 0.0;
        ELSIF OutFlowRate1 > 100.0 THEN
            OutFlowRate1 := 100.0;
        END_IF;
        
        IF OutFlowRate2 < 0.0 THEN
            OutFlowRate2 := 0.0;
        ELSIF OutFlowRate2 > 100.0 THEN
            OutFlowRate2 := 100.0;
        END_IF;
    END_IF;
END_IF;

END_FUNCTION_BLOCK