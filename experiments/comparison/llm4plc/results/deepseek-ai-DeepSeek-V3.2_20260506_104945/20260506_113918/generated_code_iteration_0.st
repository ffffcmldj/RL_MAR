START_ST
FUNCTION_BLOCK FB_SimpleCalculation
VAR_INPUT
    INPUT_VAR1 : INT := 2;
    VAR2 : INT := 0;
END_VAR

VAR_OUTPUT
    OUTPUT_VAR1 : INT;
    OUTPUT_VAR2 : INT;
END_VAR

VAR
    state : INT;
    prevState : INT;
    multCounter : INT;
    incCounter : INT;
    tempOutput1 : INT;
    tempOutput2 : INT;
END_VAR

(* State Machine Execution *)
CASE state OF
    0: (* STATE 0: INITIALIZE *)
        tempOutput1 := INPUT_VAR1;
        tempOutput2 := VAR2;
        multCounter := 0;
        incCounter := 0;
        state := 1;

    1: (* STATE 1: MULTIPLICATION_ITERATION *)
        IF multCounter < 5 THEN
            tempOutput1 := tempOutput1 * 2;
            multCounter := multCounter + 1;
            state := 2;
        ELSE
            state := 3;
        END_IF;

    2: (* STATE 2: INCREMENT_ITERATION *)
        IF incCounter < 5 THEN
            tempOutput2 := tempOutput2 + 1;
            incCounter := incCounter + 1;
            (* Check if all iterations are complete *)
            IF (multCounter >= 5) AND (incCounter >= 5) THEN
                state := 3;
            ELSE
                state := 1;
            END_IF;
        ELSE
            state := 3;
        END_IF;

    3: (* STATE 3: COMPLETED *)
        OUTPUT_VAR1 := tempOutput1;
        OUTPUT_VAR2 := tempOutput2;
        (* Remain in completed state *)
        state := 3;

END_CASE;

(* Store previous state for potential edge detection if needed in future extensions *)
prevState := state;

END_FUNCTION_BLOCK
END_ST