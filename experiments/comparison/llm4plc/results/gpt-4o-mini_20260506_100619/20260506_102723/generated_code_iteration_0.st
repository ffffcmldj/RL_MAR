ructured-text
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
    state: INT; // The state variable
END_VAR

// Initialization
state := 0;

WHILE TRUE DO
    CASE state OF
        0: // STATE 0: INITIALIZE
            state := 1; // Transition to STATE 1

        1: // STATE 1: LIMIT INPUT FLOW RATES
            IF FlowRate1 < 0 THEN
                FlowRate1 := 0;
            ELSIF FlowRate1 > 100 THEN
                FlowRate1 := 100;
            END_IF;

            IF FlowRate2 < 0 THEN
                FlowRate2 := 0;
            ELSIF FlowRate2 > 100 THEN
                FlowRate2 := 100;
            END_IF;

            state := 2; // Transition to STATE 2

        2: // STATE 2: CALCULATE TOTAL MIXED FLOW RATE
            MixedFlowRate := FlowRate1 + FlowRate2;
            state := 3; // Transition to STATE 3

        3: // STATE 3: CALCULATE OUTPUT FLOW RATES
            IF MixedFlowRate > 0 THEN
                OutFlowRate1 := (FlowRate1 / MixedFlowRate) * (FlowRate1 + FlowRate2);
                OutFlowRate2 := (FlowRate2 / MixedFlowRate) * (FlowRate1 + FlowRate2);
            ELSE
                OutFlowRate1 := 0;
                OutFlowRate2 := 0;
            END_IF;

            state := 4; // Transition to STATE 4

        4: // STATE 4: LIMIT OUTPUT FLOW RATES
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

            state := 0; // Transition back to STATE 0 to repeat the cycle
    END_CASE;
END_WHILE;

END_FUNCTION_BLOCK