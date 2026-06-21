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
    Fraction1: REAL;
    Fraction2: REAL;
    PrelimOut1: REAL;
    PrelimOut2: REAL;
END_VAR

// Step 1: Input validation and range limiting
// Limit FlowRate1 to range 0-100
IF FlowRate1 < 0.0 THEN
    LimitedFlowRate1 := 0.0;
ELSIF FlowRate1 > 100.0 THEN
    LimitedFlowRate1 := 100.0;
ELSE
    LimitedFlowRate1 := FlowRate1;
END_IF;

// Limit FlowRate2 to range 0-100
IF FlowRate2 < 0.0 THEN
    LimitedFlowRate2 := 0.0;
ELSIF FlowRate2 > 100.0 THEN
    LimitedFlowRate2 := 100.0;
ELSE
    LimitedFlowRate2 := FlowRate2;
END_IF;

// Step 2: Calculate total mixed flow rate
MixedFlowRate := LimitedFlowRate1 + LimitedFlowRate2;

// Step 3: Output flow rate calculation with error handling
// Check for invalid MixRatio to prevent division by zero
IF MixRatio <= 0.0 THEN
    // Invalid mixing ratio - set outputs to 0
    PrelimOut1 := 0.0;
    PrelimOut2 := 0.0;
ELSE
    // Calculate fractions based on mixing ratio
    Fraction1 := MixRatio / (MixRatio + 1.0);
    Fraction2 := 1.0 / (MixRatio + 1.0);
    
    // Calculate preliminary output flow rates
    PrelimOut1 := MixedFlowRate * Fraction1;
    PrelimOut2 := MixedFlowRate * Fraction2;
END_IF;

// Step 4: Output range limiting
// Limit OutFlowRate1 to range 0-100
IF PrelimOut1 < 0.0 THEN
    OutFlowRate1 := 0.0;
ELSIF PrelimOut1 > 100.0 THEN
    OutFlowRate1 := 100.0;
ELSE
    OutFlowRate1 := PrelimOut1;
END_IF;

// Limit OutFlowRate2 to range 0-100
IF PrelimOut2 < 0.0 THEN
    OutFlowRate2 := 0.0;
ELSIF PrelimOut2 > 100.0 THEN
    OutFlowRate2 := 100.0;
ELSE
    OutFlowRate2 := PrelimOut2;
END_IF;

END_FUNCTION_BLOCK