(*
    FUNCTION_BLOCK: FB_ExpandedPoint
    Description: Processes input values and assigns specific constant values to outputs.
    Inputs:
        INPUT_VAR2   : INT - Directly passed to OUTPUT_VAR2.
        INPUT_VAR1_X : INT - Unused input.
        INPUT_VAR1_Y : INT - Unused input.
        INPUT_VAR3_X : INT := 1 - Unused input with default value.
        INPUT_VAR3_Y : INT := 2 - Unused input with default value.
    Outputs:
        OUTPUT_VAR2   : INT - Assigned the value of INPUT_VAR2.
        OUTPUT_VAR1_X : INT - Assigned constant value 1.
        OUTPUT_VAR1_Y : INT - Assigned constant value 2.
        OUTPUT_VAR3_X : INT - Assigned constant value 100.
        OUTPUT_VAR3_Y : INT - Assigned constant value -7000.
    Logic: Stateless, deterministic assignments executed every cycle.
*)

FUNCTION_BLOCK FB_ExpandedPoint
VAR_INPUT
    INPUT_VAR2 : INT;
    INPUT_VAR1_X : INT;
    INPUT_VAR1_Y : INT;
    INPUT_VAR3_X : INT := 1;
    INPUT_VAR3_Y : INT := 2;
END_VAR

VAR_OUTPUT
    OUTPUT_VAR2 : INT;
    OUTPUT_VAR1_X : INT;
    OUTPUT_VAR1_Y : INT;
    OUTPUT_VAR3_X : INT;
    OUTPUT_VAR3_Y : INT;
END_VAR

// No internal variables required for this stateless function block.

// --- Main Execution Logic ---
// Executes unconditionally every cycle.
OUTPUT_VAR2 := INPUT_VAR2;
OUTPUT_VAR1_X := 1;
OUTPUT_VAR1_Y := 2;
OUTPUT_VAR3_X := 100;
OUTPUT_VAR3_Y := -7000;

END_FUNCTION_BLOCK