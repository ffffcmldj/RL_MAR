TYPE
    // Enumeration for sort direction (for internal clarity)
    SortDirectionEnum : (Ascending, Descending);
    
    // Enumeration for status codes (mapping to required WORD values)
    ShellSortStatusEnum : (Success := 16#0000, SizeTooSmall := 16#8200, SizeTooLarge := 16#8201);
END_TYPE

FUNCTION_BLOCK ShellSortFB
VAR_INPUT
    // Input Variables
    sortDirection : BOOL;  // FALSE = Ascending, TRUE = Descending
    arr : ARRAY[1..1000] OF DINT;  // Fixed-length input array
END_VAR

VAR_OUTPUT
    // Output Variables
    error : BOOL;  // FALSE: No error, TRUE: Error occurred
    status : WORD;  // Status code (16#0000, 16#8200, or 16#8201)
    sorted_arr : ARRAY[1..1000] OF DINT;  // Sorted output array
END_VAR

VAR
    // Algorithm Variables
    gap : DINT;
    i : DINT;
    j : DINT;
    temp : DINT;
    n : DINT := 1000;  // Fixed array size
    dirMultiplier : DINT;  // Direction multiplier for comparison
    
    // Internal State
    internalStatus : ShellSortStatusEnum;
END_VAR

// 1. Copy input array to output array
sorted_arr := arr;

// 2. Initialize default status (no error)
error := FALSE;
status := 16#0000;
internalStatus := Success;

// 3. Validate array size against fixed constraints
IF n <= 1 THEN
    error := TRUE;
    internalStatus := SizeTooSmall;
ELSIF n > 1000 THEN
    error := TRUE;
    internalStatus := SizeTooLarge;
END_IF;

// 4. Map internal status to output WORD
CASE internalStatus OF
    Success: status := 16#0000;
    SizeTooSmall: status := 16#8200;
    SizeTooLarge: status := 16#8201;
END_CASE;

// 5. If validation failed, return immediately
IF error THEN
    RETURN;
END_IF;

// 6. Set direction multiplier for comparison logic
// For ascending (sortDirection = FALSE): multiplier = 1
// For descending (sortDirection = TRUE): multiplier = -1
IF sortDirection THEN
    dirMultiplier := -1;
ELSE
    dirMultiplier := 1;
END_IF;

// 7. Implement Shell Sort algorithm with optimized gap sequence for 1000 elements
// Using gap sequence: 1000, 500, 250, 125, 62, 31, 15, 7, 3, 1
gap := 1000;
WHILE gap > 0 DO
    i := gap + 1;
    WHILE i <= n DO
        temp := sorted_arr[i];
        j := i;
        
        // Modified comparison for direction control
        // (sorted_arr[j - gap] - temp) * dirMultiplier > 0
        // This handles both ascending and descending orders
        WHILE (j > gap) AND ((sorted_arr[j - gap] - temp) * dirMultiplier > 0) DO
            sorted_arr[j] := sorted_arr[j - gap];
            j := j - gap;
        END_WHILE;
        
        sorted_arr[j] := temp;
        i := i + 1;
    END_WHILE;
    
    // Update gap for next iteration
    CASE gap OF
        1000: gap := 500;
        500: gap := 250;
        250: gap := 125;
        125: gap := 62;
        62: gap := 31;
        31: gap := 15;
        15: gap := 7;
        7: gap := 3;
        3: gap := 1;
        1: gap := 0;
    END_CASE;
END_WHILE;

END_FUNCTION_BLOCK;