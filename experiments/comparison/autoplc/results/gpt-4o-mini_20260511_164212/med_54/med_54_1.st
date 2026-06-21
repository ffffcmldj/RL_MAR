FUNCTION_BLOCK FeedForwardControl
VAR_INPUT
    FlowRate1: REAL; // Input flow rate of reactant 1
    FlowRate2: REAL; // Input flow rate of reactant 2
    MixRatio: REAL; // Desired mixing ratio (Reactant1:Reactant2)
END_VAR

VAR_OUTPUT
    OutFlowRate1: REAL; // Output flow rate for reactant 1
    OutFlowRate2: REAL; // Output flow rate for reactant 2
END_VAR

VAR
    MixedFlowRate: REAL; // Total mixed flow rate
    TotalParts: REAL; // Total parts of the mixing ratio
    ValidFlowRate1: REAL; // Validated flow rate for reactant 1
    ValidFlowRate2: REAL; // Validated flow rate for reactant 2
END_VAR

// Input Validation
IF FlowRate1 < 0 THEN
    ValidFlowRate1 := 0;
ELSIF FlowRate1 > 100 THEN
    ValidFlowRate1 := 100;
ELSE
    ValidFlowRate1 := FlowRate1;
END_IF;

IF FlowRate2 < 0 THEN
    ValidFlowRate2 := 0;
ELSIF FlowRate2 > 100 THEN
    ValidFlowRate2 := 100;
ELSE
    ValidFlowRate2 := FlowRate2;
END_IF;

// Calculate Total Mixed Flow Rate
MixedFlowRate := ValidFlowRate1 + ValidFlowRate2;

// Output Flow Rate Calculation
IF MixedFlowRate > 0 THEN
    TotalParts := MixRatio + 1; // Assuming MixRatio is in the form of Reactant1:Reactant2
    OutFlowRate1 := (ValidFlowRate1 / MixedFlowRate) * (MixedFlowRate * (MixRatio / TotalParts));
    OutFlowRate2 := (ValidFlowRate2 / MixedFlowRate) * (MixedFlowRate * (1 / TotalParts));
ELSE
    OutFlowRate1 := 0; // Prevent division by zero
    OutFlowRate2 := 0; // Prevent division by zero
END_IF;

// Output Flow Rate Limitation
IF OutFlowRate1 < 0 THEN
    OutFlowRate1 := 0;
ELSIF OutFlowRate1 > 100 THEN
    OutFlowRate1 := 100;
END_IF;

IF OutFlowRate2 < 0 THEN
    OutFlowRate2 := 0;
ELSIF OutFlowRate2 > 100 THEN
    OutFlowRate2 := 100;
END_IF;

END_FUNCTION_BLOCK