START_ST
FUNCTION_BLOCK FeedForwardControl
VAR_INPUT
    FlowRate1, FlowRate2: REAL; // Input flow rates of reactants
    MixRatio: REAL; // Desired mixing ratio (Reactant1:Reactant2)
END_VAR

VAR_OUTPUT
    OutFlowRate1, OutFlowRate2: REAL; // Output flow rates for reactants to maintain the mixing ratio
END_VAR

VAR
    ClampedFlowRate1, ClampedFlowRate2: REAL; // Temporary variables for clamped inputs
    MixedFlowRate: REAL; // Total mixed flow rate
    RatioFactor1, RatioFactor2: REAL; // Helper variables for ratio distribution
    OutFlowRate1_Calc, OutFlowRate2_Calc: REAL; // Temporary variables for calculated outputs
    ErrorFlag: BOOL; // Flag to indicate division by zero or invalid state
END_VAR

// STATE 0: INITIALIZE_INPUTS
// Purpose: Validate and clamp Input FlowRate1 and FlowRate2 to the range [0, 100].
// Action: If input < 0, set to 0. If input > 100, set to 100.
ClampedFlowRate1 := MAX(0.0, MIN(100.0, FlowRate1));
ClampedFlowRate2 := MAX(0.0, MIN(100.0, FlowRate2));

// STATE 1: CALCULATE_TOTAL_FLOW
// Purpose: Sum the clamped input flow rates.
// Action: MixedFlowRate = ClampedFlowRate1 + ClampedFlowRate2.
MixedFlowRate := ClampedFlowRate1 + ClampedFlowRate2;

// STATE 2: CHECK_DIVISION_ZERO
// Purpose: Prevent division by zero when calculating ratios.
// Action: If MixedFlowRate is 0, flag an error state or set outputs to 0.
IF MixedFlowRate = 0.0 THEN
    ErrorFlag := TRUE;
    OutFlowRate1_Calc := 0.0;
    OutFlowRate2_Calc := 0.0;
ELSE
    ErrorFlag := FALSE;
    // STATE 3: CALCULATE_OUTPUT_RATIOS
    // Purpose: Distribute the total flow based on the MixRatio.
    // Logic: MixRatio is defined as Reactant1 / Reactant2.
    // Therefore, Part1 = Total * (Ratio / (1 + Ratio))
    //          Part2 = Total * (1 / (1 + Ratio))
    RatioFactor1 := MixRatio / (MixRatio + 1.0);
    RatioFactor2 := 1.0 / (MixRatio + 1.0);
    
    OutFlowRate1_Calc := MixedFlowRate * RatioFactor1;
    OutFlowRate2_Calc := MixedFlowRate * RatioFactor2;
END_IF;

// STATE 4: CLAMP_OUTPUTS
// Purpose: Ensure calculated output flow rates are within [0, 100].
// Action: If OutFlowRate1 < 0 set to 0; if > 100 set to 100. Same for OutFlowRate2.
IF ErrorFlag = FALSE THEN
    OutFlowRate1 := MAX(0.0, MIN(100.0, OutFlowRate1_Calc));
    OutFlowRate2 := MAX(0.0, MIN(100.0, OutFlowRate2_Calc));
ELSE
    // If error (division by zero), outputs remain 0.0 as initialized above.
    OutFlowRate1 := 0.0;
    OutFlowRate2 := 0.0;
END_IF;

// STATE 5: FINALIZE_OUTPUTS
// Purpose: Assign final values to Output variables.
// Action: Assign clamped values to OutFlowRate1 and OutFlowRate2.
// (Values are already assigned in State 4, this step is implicit in the sequential execution)

END_FUNCTION_BLOCK
END_ST