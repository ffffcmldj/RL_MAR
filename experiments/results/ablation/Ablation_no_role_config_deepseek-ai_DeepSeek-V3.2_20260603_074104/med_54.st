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
    TempFlowRate1: REAL;
    TempFlowRate2: REAL;
    LimitedFlowRate1: REAL;
    LimitedFlowRate2: REAL;
END_VAR

// 1. VALIDATE AND LIMIT INPUT FLOW RATES (0 to 100)
IF FlowRate1 < 0.0 THEN
    LimitedFlowRate1 := 0.0;
ELSIF FlowRate1 > 100.0 THEN
    LimitedFlowRate1 := 100.0;
ELSE
    LimitedFlowRate1 := FlowRate1;
END_IF;

IF FlowRate2 < 0.0 THEN
    LimitedFlowRate2 := 0.0;
ELSIF FlowRate2 > 100.0 THEN
    LimitedFlowRate2 := 100.0;
ELSE
    LimitedFlowRate2 := FlowRate2;
END_IF;

// 2. CALCULATE TOTAL MIXED FLOW RATE
MixedFlowRate := LimitedFlowRate1 + LimitedFlowRate2;

// 3. CALCULATE OUTPUT FLOW RATES WITH ERROR HANDLING
IF MixRatio = 0.0 THEN
    // Prevent division by zero - use equal distribution
    TempFlowRate1 := MixedFlowRate / 2.0;
    TempFlowRate2 := MixedFlowRate / 2.0;
ELSE
    // Calculate based on mixing ratio: MixRatio = Reactant1:Reactant2
    // For ratio a:b, Reactant1 fraction = a/(a+b)
    TempFlowRate1 := MixedFlowRate * (MixRatio / (MixRatio + 1.0));
    TempFlowRate2 := MixedFlowRate * (1.0 / (MixRatio + 1.0));
END_IF;

// 4. LIMIT OUTPUT FLOW RATES TO ALLOWED RANGE (0 to 100)
IF TempFlowRate1 < 0.0 THEN
    OutFlowRate1 := 0.0;
ELSIF TempFlowRate1 > 100.0 THEN
    OutFlowRate1 := 100.0;
ELSE
    OutFlowRate1 := TempFlowRate1;
END_IF;

IF TempFlowRate2 < 0.0 THEN
    OutFlowRate2 := 0.0;
ELSIF TempFlowRate2 > 100.0 THEN
    OutFlowRate2 := 100.0;
ELSE
    OutFlowRate2 := TempFlowRate2;
END_IF;

// 5. ENSURE OUTPUT CONSISTENCY (Optional safeguard)
// Additional check to ensure outputs don't exceed total mixed flow rate
IF (OutFlowRate1 + OutFlowRate2) > MixedFlowRate THEN
    // Scale down proportionally if needed
    TempFlowRate1 := OutFlowRate1;
    TempFlowRate2 := OutFlowRate2;
    OutFlowRate1 := TempFlowRate1 * (MixedFlowRate / (TempFlowRate1 + TempFlowRate2));
    OutFlowRate2 := TempFlowRate2 * (MixedFlowRate / (TempFlowRate1 + TempFlowRate2));
END_IF;

END_FUNCTION_BLOCK