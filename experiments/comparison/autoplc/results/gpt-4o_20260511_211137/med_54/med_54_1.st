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
    TotalRatio: REAL; // Sum of MixRatio and 1 for calculation
    Ratio1, Ratio2: REAL; // Ratios for output calculation
END_VAR

// Input Validation and Limiting
IF FlowRate1 < 0.0 THEN
    FlowRate1 := 0.0;
ELSIF FlowRate1 > 100.0 THEN
    FlowRate1 := 100.0;
END_IF

IF FlowRate2 < 0.0 THEN
    FlowRate2 := 0.0;
ELSIF FlowRate2 > 100.0 THEN
    FlowRate2 := 100.0;
END_IF

// Total Mixed Flow Rate Calculation
MixedFlowRate := FlowRate1 + FlowRate2;

// Mixing Ratio Application
TotalRatio := MixRatio + 1.0; // Total ratio for calculation
IF TotalRatio = 0.0 THEN
    Ratio1 := 0.0;
    Ratio2 := 0.0;
ELSE
    Ratio1 := MixRatio / TotalRatio;
    Ratio2 := 1.0 / TotalRatio;
END_IF

// Output Flow Rate Calculation
IF MixedFlowRate = 0.0 THEN
    OutFlowRate1 := 0.0;
    OutFlowRate2 := 0.0;
ELSE
    OutFlowRate1 := MixedFlowRate * Ratio1;
    OutFlowRate2 := MixedFlowRate * Ratio2;
END_IF

// Output Validation and Limiting
IF OutFlowRate1 < 0.0 THEN
    OutFlowRate1 := 0.0;
ELSIF OutFlowRate1 > 100.0 THEN
    OutFlowRate1 := 100.0;
END_IF

IF OutFlowRate2 < 0.0 THEN
    OutFlowRate2 := 0.0;
ELSIF OutFlowRate2 > 100.0 THEN
    OutFlowRate2 := 100.0;
END_IF

END_FUNCTION_BLOCK