ructured-text
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
    state : INT; // THE STATE VARIABLE
    i : INT; // LOOP COUNTER FOR ITERATION
    tempValue : DINT; // TEMPORARY VARIABLE FOR CURRENT ARRAY ELEMENT
END_VAR

// STATE 0: INITIALIZE
state := 0;

// STATE MACHINE
CASE state OF
    0:
        // Initialize minValue and maxValue to the first element of the array
        minValue := values[1];
        minValueIndex := 1;
        maxValue := values[1];
        maxValueIndex := 1;
        // Transition to STATE 1
        state := 1;

    1:
        // Iterate through the array
        FOR i := 1 TO 10 DO
            tempValue := values[i];
            IF tempValue < minValue THEN
                minValue := tempValue;
                minValueIndex := i;
            END_IF;
            IF tempValue > maxValue THEN
                maxValue := tempValue;
                maxValueIndex := i;
            END_IF;
        END_FOR;
        // Transition to STATE 2
        state := 2;

    2:
        // Return the values (outputs are already set)
        // End of processing
        // Note: In a real implementation, you might reset the state or handle further logic here.
END_CASE;

END_FUNCTION_BLOCK