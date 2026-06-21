FUNCTION_BLOCK FeedForwardControl
VAR_INPUT
    FlowRate1: REAL;
    FlowRate2: REAL;
    MixRatio: REAL;
END_VAR

VAR_OUTPUT
    OutFlowRate1: REAL;
    OutFlowRate2: REAL;
END_VAR

VAR
    MixedFlowRate: REAL;
    TempFlow1: REAL;
    TempFlow2: REAL;
END_VAR

(* Limit input flow rates to 0-100 range *)
IF FlowRate1 < 0.0 THEN
    TempFlow1 := 0.0;
ELSIF FlowRate1 > 100.0 THEN
    TempFlow1 := 100.0;
ELSE
    TempFlow1 := FlowRate1;
END_IF;

IF FlowRate2 < 0.0 THEN
    TempFlow2 := 0.0;
ELSIF FlowRate2 > 100.0 THEN
    TempFlow2 := 100.0;
ELSE
    TempFlow2 := FlowRate2;
END_IF;

(* Calculate total mixed flow rate *)
MixedFlowRate := TempFlow1 + TempFlow2;

(* Calculate output flow rates with division by zero protection *)
IF (MixRatio + 1.0) <> 0.0 AND MixedFlowRate <> 0.0 THEN
    OutFlowRate1 := MixedFlowRate * (MixRatio / (MixRatio + 1.0));
    OutFlowRate2 := MixedFlowRate * (1.0 / (MixRatio + 1.0));
ELSE
    OutFlowRate1 := 0.0;
    OutFlowRate2 := 0.0;
END_IF;

(* Limit output flow rates to 0-100 range *)
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

END_FUNCTION_BLOCK;