FUNCTION_BLOCK FB_Sum
    VAR_INPUT
        maxValue : INT;
    END_VAR
    VAR_OUTPUT
        wData : WORD;
    END_VAR
    VAR
        II : INT;
    END_VAR

    // Initialize wData to 0
    wData := 0;

    // Use a FOR loop to iterate from 0 to maxValue
    FOR II := 0 TO maxValue DO
        // Increment wData by the loop index II
        wData := wData + II;
    END_FOR
END_FUNCTION_BLOCK