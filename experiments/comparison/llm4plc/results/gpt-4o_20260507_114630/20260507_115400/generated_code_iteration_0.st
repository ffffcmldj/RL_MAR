plaintext
START_ST
FUNCTION_BLOCK FB_WarehouseManagement

VAR_INPUT
    requestIn : BOOL := FALSE; // Request to store a new product
    requestOut : BOOL := FALSE; // Request to retrieve a product
END_VAR

VAR_OUTPUT
    productNum : INT := 0; // Current number of stored products
    libFreeNum : INT := 9; // Number of available storage positions
    error : BOOL := FALSE; // Error status indicator
    status : WORD := 16#0000; // Detailed error code
END_VAR

VAR_IN_OUT
    library : ARRAY[1..9] OF BOOL; // Storage position status array
END_VAR

VAR
    state : INT := 0; // Current state of the FSM
    prevState : INT := 0; // Previous state of the FSM
    i : INT; // Loop index for searching storage positions
    found : BOOL; // Indicates whether a free or occupied position was found
    errFull : WORD := 16#8001; // Error code for storage full
    errEmpty : WORD := 16#8002; // Error code for storage empty
END_VAR

// Main logic
IF state = 0 THEN // STATE 0: IDLE
    // Reset error flags and status
    error := FALSE;
    status := 16#0000;

    // Transition logic
    IF requestIn AND (productNum < 9) THEN
        state := 2; // Transition to STORE PRODUCT
    ELSIF requestOut AND (productNum > 0) THEN
        state := 3; // Transition to RETRIEVE PRODUCT
    ELSIF requestIn AND (productNum >= 9) THEN
        state := 4; // Transition to ERROR HANDLING (Storage Full)
    ELSIF requestOut AND (productNum <= 0) THEN
        state := 4; // Transition to ERROR HANDLING (Storage Empty)
    END_IF;

ELSIF state = 1 THEN // STATE 1: INITIALIZE
    // Initialize library array to all FALSE
    i := 1;
    WHILE i <= 9 DO
        library[i] := FALSE;
        i := i + 1;
    END_WHILE;

    // Initialize counters
    productNum := 0;
    libFreeNum := 9;

    // Reset error flags and status
    error := FALSE;
    status := 16#0000;

    // Transition back to IDLE
    state := 0;

ELSIF state = 2 THEN // STATE 2: STORE PRODUCT
    // Search for a free position from highest to lowest index
    i := 9;
    found := FALSE;
    WHILE (i >= 1) AND NOT found DO
        IF NOT library[i] THEN
            library[i] := TRUE; // Mark position as occupied
            found := TRUE;
        ELSE
            i := i - 1;
        END_IF;
    END_WHILE;

    // Update counters
    IF found THEN
        productNum := productNum + 1;
        libFreeNum := libFreeNum - 1;

        // Check for storage full error
        IF productNum >= 9 THEN
            error := TRUE;
            status := errFull;
        END_IF;
    END_IF;

    // Transition back to IDLE
    state := 0;

ELSIF state = 3 THEN // STATE 3: RETRIEVE PRODUCT
    // Search for an occupied position from lowest to highest index
    i := 1;
    found := FALSE;
    WHILE (i <= 9) AND NOT found DO
        IF library[i] THEN
            library[i] := FALSE; // Mark position as free
            found := TRUE;
        ELSE
            i := i + 1;
        END_IF;
    END_WHILE;

    // Update counters
    IF found THEN
        productNum := productNum - 1;
        libFreeNum := libFreeNum + 1;

        // Check for storage empty error
        IF productNum <= 0 THEN
            error := TRUE;
            status := errEmpty;
        END_IF;
    END_IF;

    // Transition back to IDLE
    state := 0;

ELSIF state = 4 THEN // STATE 4: ERROR HANDLING
    // Set appropriate error flags and status
    IF productNum >= 9 THEN
        error := TRUE;
        status := errFull; // Storage full error
    ELSIF productNum <= 0 THEN
        error := TRUE;
        status := errEmpty; // Storage empty error
    END_IF;

    // Transition back to IDLE
    state := 0;

END_IF;

END_FUNCTION_BLOCK
END_ST