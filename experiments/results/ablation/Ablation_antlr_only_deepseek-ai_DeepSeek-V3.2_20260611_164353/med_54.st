FUNCTION_BLOCK FeedForwardControl
VAR_INPUT
    FlowRate1 : REAL; (* Input flow rate of reactant 1 *)
    FlowRate2 : REAL; (* Input flow rate of reactant 2 *)
    MixRatio : REAL;  (* Desired mixing ratio (Reactant1:Reactant2) *)
END_VAR

VAR_OUTPUT
    OutFlowRate1 : REAL; (* Output flow rate for reactant 1 *)
    OutFlowRate2 : REAL; (* Output flow rate for reactant 2 *)
END_VAR

VAR
    MixedFlowRate : REAL; (* Total mixed flow rate *)
    FlowRate1_Clamped : REAL;
    FlowRate2_Clamped : REAL;
    MixRatio_Clamped : REAL;
END_VAR

(* 1. Input Validation and Clamping *)
FlowRate1_Clamped := LIMIT(0.0, FlowRate1, 100.0);
FlowRate2_Clamped := LIMIT(0.0, FlowRate2, 100.0);
MixRatio_Clamped := MAX(0.0, MixRatio);

(* 2. Calculate Total Mixed Flow Rate *)
MixedFlowRate := FlowRate1_Clamped + FlowRate2_Clamped;

(* 3. Calculate Output Flow Rates with Error Handling *)
IF MixedFlowRate > 0.0 THEN
    OutFlowRate1 := (MixRatio_Clamped / (MixRatio_Clamped + 1.0)) * MixedFlowRate;
    OutFlowRate2 := (1.0 / (MixRatio_Clamped + 1.0)) * MixedFlowRate;
ELSE
    OutFlowRate1 := 0.0;
    OutFlowRate2 := 0.0;
END_IF;

(* 4. Output Clamping to Valid Range *)
OutFlowRate1 := LIMIT(0.0, OutFlowRate1, 100.0);
OutFlowRate2 := LIMIT(0.0, OutFlowRate2, 100.0);

END_FUNCTION_BLOCK