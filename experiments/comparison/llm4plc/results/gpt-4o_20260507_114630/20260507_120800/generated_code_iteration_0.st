plaintext
START_ST
FUNCTION_BLOCK FeedForwardControl
VAR_INPUT
    FlowRate1: REAL; // Input flow rate of Reactant 1
    FlowRate2: REAL; // Input flow rate of Reactant 2
    MixRatio: REAL;  // Desired mixing ratio (Reactant1:Reactant2)
END_VAR

VAR_OUTPUT
    OutFlowRate1: REAL; // Output flow rate for Reactant 1
    OutFlowRate2: REAL; // Output flow rate for Reactant 2
END_VAR

VAR
    MixedFlowRate: REAL; // Total mixed flow rate
END_VAR

// Step 1: Limit the input flow rates to the allowed range of 0 to 100
IF FlowRate1 < 0.0 THEN
    FlowRate1 := 0.0;
ELSIF FlowRate1 > 100.0 THEN
    FlowRate1 := 100.0;
END_IF;

IF FlowRate2 < 0.0 THEN
    FlowRate2 := 0.0;
ELSIF FlowRate2 > 100.0 THEN
    FlowRate2 := 100.0;
END_IF;

// Step 2: Calculate the total mixed flow rate
MixedFlowRate := FlowRate1 + FlowRate2;

// Step 3: Check if the MixRatio is valid
IF MixRatio <= 0.0 THEN
    OutFlowRate1 := 0.0;
    OutFlowRate2 := 0.0;
ELSE
    // Step 4: Calculate the output flow rates based on the mixing ratio
    OutFlowRate1 := MixedFlowRate * MixRatio / (1.0 + MixRatio);
    OutFlowRate2 := MixedFlowRate / (1.0 + MixRatio);

    // Step 5: Limit the output flow rates to the allowed range of 0 to 100
    IF OutFlowRate1 < 0.0 THEN
        OutFlowRate1 := 0.0;
    ELSIF OutFlowRate1 > 100.0 THEN
        OutFlowRate1 := 100.0;
    END_IF;

    IF OutFlowRate2 < 0.0 THEN
        OutFlowRate2 := 0.0;
    ELSIF OutFlowRate2 > 100.0 THEN
        OutFlowRate2 := 100.0;
    END_IF;
END_IF;

END_FUNCTION_BLOCK
END_ST