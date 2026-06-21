FUNCTION_BLOCK MultiPumpCtrl
    VAR_INPUT
        mode : BOOL; // FALSE for Manual mode, TRUE for Automatic mode
        start : BOOL; // Start button
        stop : BOOL; // Stop button
        priorities : ARRAY[1..5] OF INT; // Priority of each pump
        selections : ARRAY[1..5] OF BOOL; // Manual selection of pumps
    END_VAR

    VAR_OUTPUT
        RunComds : ARRAY[1..5] OF BOOL; // Pump run command
    END_VAR

    VAR
        i : INT; // Loop variable
        j : INT; // Loop variable for finding max priority
        maxPriority : INT; // Current maximum priority found
        maxIndex : INT; // Index of the pump with the maximum priority
        runCount : INT; // Count of pumps running in automatic mode
        usedInAuto : ARRAY[1..5] OF BOOL; // Track which pumps are used in automatic mode
    END_VAR

    // Initialization
    FOR i := 1 TO 5 DO
        RunComds[i] := FALSE; // Initialize all run commands to FALSE
        usedInAuto[i] := FALSE; // Initialize usedInAuto array
    END_FOR

    // Stop Condition
    IF stop THEN
        FOR i := 1 TO 5 DO
            RunComds[i] := FALSE; // Stop all pumps
        END_FOR;
    ELSE
        // Mode Evaluation
        IF mode THEN // Automatic Mode
            IF start THEN
                runCount := 0; // Reset run count
                FOR i := 1 TO 5 DO
                    maxPriority := -1; // Reset max priority
                    maxIndex := 0; // Reset max index
                    // Find the pump with the highest priority
                    FOR j := 1 TO 5 DO
                        IF (priorities[j] > maxPriority) AND (NOT usedInAuto[j]) THEN
                            maxPriority := priorities[j]; // Update max priority
                            maxIndex := j; // Update max index
                        END_IF;
                    END_FOR;

                    // If a valid pump is found, mark it as used and increment run count
                    IF maxIndex > 0 THEN
                        RunComds[maxIndex] := TRUE; // Set run command for the pump
                        usedInAuto[maxIndex] := TRUE; // Mark this pump as used
                        runCount := runCount + 1; // Increment the count of running pumps
                    END_IF;

                    // Stop if we have already selected 3 pumps
                    IF runCount >= 3 THEN
                        EXIT; // Exit the loop if 3 pumps are running
                    END_IF;
                END_FOR;
            END_IF;
        ELSE // Manual Mode
            IF start THEN
                FOR i := 1 TO 5 DO
                    RunComds[i] := selections[i]; // Set run commands based on manual selections
                END_FOR;
            END_IF;
        END_IF;
    END_IF;
END_FUNCTION_BLOCK