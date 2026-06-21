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
    ClampedFlow1, ClampedFlow2: REAL;
    RatioPart1, RatioPart2: REAL;
    RatioSum: REAL;
END_VAR

// Limit input flow rates to allowed range 0-100
ClampedFlow1 := LIMIT(0.0, FlowRate1, 100.0);
ClampedFlow2 := LIMIT(0.0, FlowRate2, 100.0);

// Calculate total mixed flow rate
MixedFlowRate := ClampedFlow1 + ClampedFlow2;

// Calculate mixing ratio parts with error handling to prevent division by zero
RatioSum := MixRatio + 1.0;
IF RatioSum > 0.0 THEN
    RatioPart1 := MixRatio / RatioSum;
    RatioPart2 := 1.0 / RatioSum;
ELSE
    // Handle invalid ratio (MixRatio = -1.0)
    RatioPart1 := 0.0;
    RatioPart2 := 0.0;
END_IF

// Calculate output flow rates based on mixing ratio and total flow rate
OutFlowRate1 := LIMIT(0.0, MixedFlowRate * RatioPart1, 100.0);
OutFlowRate2 := LIMIT(0.0, MixedFlowRate * RatioPart2, 100.0);

END_FUNCTION_BLOCK