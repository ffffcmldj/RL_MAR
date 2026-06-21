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
    i : INT;
    state : INT;
END_VAR

// STATE 0: INITIALIZE
state := 0;
minValue := values[1];
minValueIndex := 1;
maxValue := values[1];
maxValueIndex := 1;
i := 2;

// STATE 1: ITERATE AND COMPARE
IF state = 0 THEN
    state := 1;
END_IF;

IF state = 1 THEN
    // Compare current element with min and max
    IF values[i] < minValue THEN
        minValue := values[i];
        minValueIndex := i;
    END_IF;

    IF values[i] > maxValue THEN
        maxValue := values[i];
        maxValueIndex := i;
    END_IF;

    // Increment counter
    i := i + 1;

    // Transition Logic
    IF i <= 10 THEN
        // Remain in STATE 1 (loop continues)
        // No state change needed as logic is sequential in ST
    ELSE
        // Transition to STATE 2 (Complete)
        state := 2;
    END_IF;
END_IF;

// STATE 2: COMPLETE
// No further processing required.
// The function block naturally exits here with the final values populated.

END_FUNCTION_BLOCK
END_ST