START_ST
FUNCTION_BLOCK FindMinMaxValues
VAR_INPUT
    values : ARRAY[1..10] OF DINT;
END_VAR
VAR_OUTPUT
    minValue : DINT;
    minValueIndex : DINT;
    maxValue : DINT;
    maxValueIndex : DINT;
END_VAR
VAR
    state : INT;
    prevState : INT;
    i : INT;
    firstExecution : BOOL;
END_VAR

CASE state OF
    0: (* INITIALIZATION *)
        firstExecution := TRUE;
        minValue := 0;
        minValueIndex := 0;
        maxValue := 0;
        maxValueIndex := 0;
        i := 1;
        state := 1;
        
    1: (* SEARCHING *)
        IF firstExecution THEN
            minValue := values[1];
            minValueIndex := 1;
            maxValue := values[1];
            maxValueIndex := 1;
            firstExecution := FALSE;
        END_IF;
        
        IF (i >= 1) AND (i <= 10) THEN
            IF values[i] < minValue THEN
                minValue := values[i];
                minValueIndex := i;
            END_IF;
            
            IF values[i] > maxValue THEN
                maxValue := values[i];
                maxValueIndex := i;
            END_IF;
        END_IF;
        
        i := i + 1;
        
        IF i > 10 THEN
            state := 2;
        END_IF;
        
    2: (* COMPLETED *)
        (* Maintain final calculated values - no action needed *)
        
END_CASE;

prevState := state;

END_FUNCTION_BLOCK
END_ST