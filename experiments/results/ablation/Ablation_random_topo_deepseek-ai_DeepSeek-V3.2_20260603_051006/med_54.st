FUNCTION_BLOCK FeedForwardControl
VAR_INPUT
    FlowRate1, FlowRate2: REAL; // Input flow rates of reactants
    MixRatio: REAL; // Desired mixing ratio (Reactant1:Reactant2)
END_VAR

VAR_OUTPUT
    OutFlowRate1, OutFlowRate2: REAL; // Output flow rates for reactants to maintain the mixing ratio
END_VAR

VAR
    MixedFlowRate: REAL; // Total mixed flow rate
    LimitedFlowRate1: REAL;
    LimitedFlowRate2: REAL;
    RatioSum: REAL;
END_VAR

// Limit input flow rates to valid range (0 to 100)
LimitedFlowRate1 := LIMIT(0.0, FlowRate1, 100.0);
LimitedFlowRate2 := LIMIT(0.0, FlowRate2, 100.0);

// Calculate total mixed flow rate
MixedFlowRate := LimitedFlowRate1 + LimitedFlowRate2;

// Calculate output flow rates with error handling for division by zero
RatioSum := MixRatio + 1.0;

IF RatioSum <> 0.0 THEN
    // Calculate proportional outputs based on mixing ratio
    OutFlowRate1 := MixedFlowRate * (MixRatio / RatioSum);
    OutFlowRate2 := MixedFlowRate * (1.0 / RatioSum);
    
    // Limit output flow rates to valid range (0 to 100)
    OutFlowRate1 := LIMIT(0.0, OutFlowRate1, 100.0);
    OutFlowRate2 := LIMIT(0.0, OutFlowRate2, 100.0);
ELSE
    // Handle division by zero case (when MixRatio = -1.0)
    OutFlowRate1 := 0.0;
    OutFlowRate2 := 0.0;
END_IF;

END_FUNCTION_BLOCK