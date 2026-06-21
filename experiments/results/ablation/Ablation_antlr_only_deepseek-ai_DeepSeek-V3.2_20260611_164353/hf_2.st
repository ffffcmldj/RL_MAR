TYPE
    // Define a structure to hold the result of the min/max search
    MinMaxResult : STRUCT
        minValue : DINT;
        minValueIndex : DINT;
        maxValue : DINT;
        maxValueIndex : DINT;
    END_STRUCT;
END_TYPE

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

// Initialize with the first element
minValue := values[1];
maxValue := values[1];
minValueIndex := 1;
maxValueIndex := 1;

// Iterate through the remaining elements
FOR i := 2 TO 10 DO
    // Check for new minimum
    IF values[i] < minValue THEN
        minValue := values[i];
        minValueIndex := i;
    END_IF;
    
    // Check for new maximum
    IF values[i] > maxValue THEN
        maxValue := values[i];
        maxValueIndex := i;
    END_IF;
END_FOR;

END_FUNCTION_BLOCK;