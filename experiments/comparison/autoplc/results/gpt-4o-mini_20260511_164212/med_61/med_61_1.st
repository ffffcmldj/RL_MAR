FUNCTION_BLOCK FB_Sum
    VAR_INPUT
        maxValue : INT; // Input variable specifying the maximum value for summation
    END_VAR

    VAR_OUTPUT
        wData : WORD; // Output variable to store the sum of integers from 0 to maxValue
    END_VAR

    VAR
        II : INT; // Loop index variable
    END_VAR

    // Initialization of wData
    wData := 0;

    // Summation Logic using a FOR loop
    FOR II := 0 TO maxValue DO
        wData := wData + II; // Increment wData by the current loop index
    END_FOR

END_FUNCTION_BLOCK