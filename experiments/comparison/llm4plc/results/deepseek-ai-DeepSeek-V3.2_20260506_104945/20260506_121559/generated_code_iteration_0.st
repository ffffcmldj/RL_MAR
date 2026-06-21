START_ST
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
    LimFlowRate1: REAL;
    LimFlowRate2: REAL;
    CalcOut1: REAL;
    CalcOut2: REAL;
    RatioValid: BOOL;
END_VAR

(* Limit input flow rates to the allowed range 0..100 *)
LimFlowRate1 := LIMIT(0.0, FlowRate1, 100.0);
LimFlowRate2 := LIMIT(0.0, FlowRate2, 100.0);

(* Calculate total mixed flow rate *)
MixedFlowRate := LimFlowRate1 + LimFlowRate2;

(* Validate MixRatio to prevent division by zero; assume positive ratio *)
RatioValid := (MixRatio > 0.0);

IF RatioValid THEN
    (* Calculate output flow rates based on mixing ratio *)
    CalcOut1 := MixedFlowRate * (MixRatio / (1.0 + MixRatio));
    CalcOut2 := MixedFlowRate * (1.0 / (1.0 + MixRatio));
    
    (* Limit output flow rates to the allowed range 0..100 *)
    OutFlowRate1 := LIMIT(0.0, CalcOut1, 100.0);
    OutFlowRate2 := LIMIT(0.0, CalcOut2, 100.0);
ELSE
    (* Invalid MixRatio: set outputs to safe default (0.0) *)
    OutFlowRate1 := 0.0;
    OutFlowRate2 := 0.0;
END_IF;

END_FUNCTION_BLOCK
END_ST