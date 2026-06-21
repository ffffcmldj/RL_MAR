FUNCTION_BLOCK MultiPumpCtrl
VAR_INPUT
    mode : BOOL;                    // FALSE = Manual, TRUE = Automatic
    start : BOOL;                   // Start button
    stop : BOOL;                    // Stop button (highest priority)
    priorities : ARRAY[1..5] OF INT; // Pump priorities (higher value = higher priority)
    selections : ARRAY[1..5] OF BOOL; // Manual mode selections
END_VAR

VAR_OUTPUT
    RunComds : ARRAY[1..5] OF BOOL; // Pump run commands
END_VAR

VAR
    i : INT;                        // Loop counter
    j : INT;                        // Loop counter for bubble sort
    tempPriority : INT;             // Temporary variable for priority swap
    tempIndex : INT;                // Temporary variable for index swap
    sortedPriorities : ARRAY[1..5] OF INT;  // Copy of priorities for sorting
    sortedIndices : ARRAY[1..5] OF INT;     // Original indices after sorting
END_VAR

// Main logic
IF stop THEN
    // Highest priority: stop all pumps
    FOR i := 1 TO 5 DO
        RunComds[i] := FALSE;
    END_FOR;
ELSIF start THEN
    IF NOT mode THEN
        // Manual mode: directly use selections
        FOR i := 1 TO 5 DO
            RunComds[i] := selections[i];
        END_FOR;
    ELSE
        // Automatic mode: find 3 highest priority pumps
        
        // Initialize arrays for sorting
        FOR i := 1 TO 5 DO
            sortedPriorities[i] := priorities[i];
            sortedIndices[i] := i;
            RunComds[i] := FALSE;  // Start with all pumps stopped
        END_FOR;
        
        // Simple bubble sort to sort by priority (descending)
        // This ensures stable selection when priorities are equal
        FOR i := 1 TO 4 DO
            FOR j := i + 1 TO 5 DO
                IF sortedPriorities[j] > sortedPriorities[i] THEN
                    // Swap priorities
                    tempPriority := sortedPriorities[i];
                    sortedPriorities[i] := sortedPriorities[j];
                    sortedPriorities[j] := tempPriority;
                    
                    // Swap corresponding indices
                    tempIndex := sortedIndices[i];
                    sortedIndices[i] := sortedIndices[j];
                    sortedIndices[j] := tempIndex;
                END_IF;
            END_FOR;
        END_FOR;
        
        // Activate top 3 pumps after sorting
        FOR i := 1 TO 3 DO
            RunComds[sortedIndices[i]] := TRUE;
        END_FOR;
    END_IF;
ELSE
    // start = FALSE: maintain current state (no action)
    // Note: In a real PLC system, you might want to explicitly maintain state
    // but the requirement implies we don't change outputs when start is false
END_IF;

END_FUNCTION_BLOCK;