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
    END_VAR

    // Initialization
    minValue := values[1];
    maxValue := values[1];
    minValueIndex := 1;
    maxValueIndex := 1;

    // Iteration through the array
    FOR i := 1 TO 10 DO
        // Check for minimum value
        IF values[i] < minValue THEN
            minValue := values[i];
            minValueIndex := i;
        END_IF;

        // Check for maximum value
        IF values[i] > maxValue THEN
            maxValue := values[i];
            maxValueIndex := i;
        END_IF;
    END_FOR;
END_FUNCTION_BLOCK