FUNCTION_BLOCK FeedForwardControl
VAR_INPUT
    FlowRate1 : REAL; (* Input flow rate of reactant 1 *)
    FlowRate2 : REAL; (* Input flow rate of reactant 2 *)
    MixRatio  : REAL; (* Desired mixing ratio (Reactant1:Reactant2) *)
END_VAR

VAR_OUTPUT
    OutFlowRate1 : REAL; (* Output flow rate for reactant 1 *)
    OutFlowRate2 : REAL; (* Output flow rate for reactant 2 *)
END_VAR

VAR
    MixedFlowRate    : REAL; (* Total mixed flow rate *)
    ClampedFlowRate1 : REAL; (* Clamped input flow rate 1 *)
    ClampedFlowRate2 : REAL; (* Clamped input flow rate 2 *)
    RatioFactor1     : REAL; (* Ratio factor for reactant 1 *)
    RatioFactor2     : REAL; (* Ratio factor for reactant 2 *)
    PreliminaryOut1  : REAL; (* Preliminary output flow rate 1 *)
    PreliminaryOut2  : REAL; (* Preliminary output flow rate 2 *)
END_VAR

(* --- INPUT VALIDATION & CLAMPING --- *)
(* Ensure input flow rates are within the valid operating range [0, 100] *)
ClampedFlowRate1 := LIMIT(0.0, FlowRate1, 100.0);
ClampedFlowRate2 := LIMIT(0.0, FlowRate2, 100.0);

(* --- TOTAL FLOW CALCULATION --- *)
MixedFlowRate := ClampedFlowRate1 + ClampedFlowRate2;

(* --- OUTPUT CALCULATION WITH RATIO HANDLING --- *)
(* Check for invalid mixing ratio to prevent division by zero *)
IF MixRatio <> 0.0 THEN
    (* Calculate ratio factors based on MixRatio = Reactant1:Reactant2 *)
    RatioFactor1 := MixRatio / (MixRatio + 1.0);
    RatioFactor2 := 1.0 / (MixRatio + 1.0);
    
    (* Calculate preliminary output flow rates *)
    PreliminaryOut1 := MixedFlowRate * RatioFactor1;
    PreliminaryOut2 := MixedFlowRate * RatioFactor2;
ELSE
    (* Invalid mixing ratio: fallback to equal distribution *)
    PreliminaryOut1 := MixedFlowRate * 0.5;
    PreliminaryOut2 := MixedFlowRate * 0.5;
END_IF;

(* --- OUTPUT CLAMPING --- *)
(* Ensure final output flow rates are within the valid operating range [0, 100] *)
OutFlowRate1 := LIMIT(0.0, PreliminaryOut1, 100.0);
OutFlowRate2 := LIMIT(0.0, PreliminaryOut2, 100.0);

END_FUNCTION_BLOCK