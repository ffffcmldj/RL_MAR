(*
    FUNCTION_BLOCK: FindMinMaxValues
    Description: Finds the minimum and maximum values in a fixed-size array of integers
                and returns their values and positions (indices).
    Inputs:
        values : ARRAY[1..10] OF DINT - The array to be searched.
    Outputs:
        minValue : DINT - The minimum value found in the array.
        minValueIndex : DINT - The position (index) of the minimum value.
        maxValue : DINT - The maximum value found in the array.
        maxValueIndex : DINT - The position (index) of the maximum value.
    Implementation:
        Initializes min and max to the first element, then iterates through the
        remaining elements. Updates values and indices when a new min or max is found.
        Correctly handles edge cases (e.g., all elements equal, first element is min/max).
*)

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

    (* Initialize with the first element *)
    minValue := values[1];
    maxValue := values[1];
    minValueIndex := 1;
    maxValueIndex := 1;

    (* Iterate through the rest of the array (elements 2 to 10) *)
    FOR i := 2 TO 10 DO
        IF values[i] < minValue THEN
            minValue := values[i];
            minValueIndex := i;
        END_IF;
        IF values[i] > maxValue THEN
            maxValue := values[i];
            maxValueIndex := i;
        END_IF;
    END_FOR;

END_FUNCTION_BLOCK;