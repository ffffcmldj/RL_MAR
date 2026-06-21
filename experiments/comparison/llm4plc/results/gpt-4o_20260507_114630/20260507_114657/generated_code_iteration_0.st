plaintext
START_ST
FUNCTION_BLOCK FindMinMaxValues
VAR_INPUT
    values: ARRAY[1..10] OF DINT; // Input array of integers
END_VAR
VAR_OUTPUT
    minValue: DINT; // Minimum value in the array
    minValueIndex: DINT; // Index of the minimum value
    maxValue: DINT; // Maximum value in the array
    maxValueIndex: DINT; // Index of the maximum value
END_VAR
VAR
    i: INT; // Loop counter
END_VAR

// Initialize minValue and maxValue to the first element of the array
minValue := values[1];
maxValue := values[1];

// Initialize minValueIndex and maxValueIndex to 1
minValueIndex := 1;
maxValueIndex := 1;

// Iterate through the array from index 2 to 10
FOR i := 2 TO 10 DO
    // Check if the current element is less than minValue
    IF values[i] < minValue THEN
        minValue := values[i]; // Update minValue
        minValueIndex := i;    // Update minValueIndex
    END_IF;

    // Check if the current element is greater than maxValue
    IF values[i] > maxValue THEN
        maxValue := values[i]; // Update maxValue
        maxValueIndex := i;    // Update maxValueIndex
    END_IF;
END_FOR;

END_FUNCTION_BLOCK
END_ST