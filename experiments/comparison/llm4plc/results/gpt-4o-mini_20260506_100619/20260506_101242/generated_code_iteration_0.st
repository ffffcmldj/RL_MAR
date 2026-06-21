ructured-text
START_ST
FUNCTION_BLOCK FB_WarehouseManagement

VAR_INPUT 
    requestIn : BOOL := FALSE;
    requestOut : BOOL := FALSE;
END_VAR

VAR_OUTPUT 
    productNum : INT := 0;
    libFreeNum : INT := 9;
    error : BOOL := FALSE;
    status : WORD := 16#0000;
END_VAR

VAR_IN_OUT 
    library : ARRAY[1..9] OF BOOL;
END_VAR

VAR 
    state : INT; // THE STATE VARIABLE
    prevState : INT; // THE PREVIOUS STATE VARIABLE
    i : INT; // LOOP INDEX VARIABLE
    found : BOOL; // FLAG TO INDICATE IF A POSITION WAS FOUND
    errFull : WORD := 16#8001; // ERROR CODE FOR FULL STORAGE
    errEmpty : WORD := 16#8002; // ERROR CODE FOR EMPTY STORAGE
END_VAR

// Initialization State
state := 0; // Start in the initialization state

WHILE TRUE DO
    CASE state OF
        0: // INITIALIZE
            productNum := 0;
            libFreeNum := 9;
            error := FALSE;
            status := 16#0000;
            FOR i := 1 TO 9 DO
                library[i] := FALSE; // Initialize all positions as free
            END_FOR;
            state := 1; // Transition to handle requests

        1: // HANDLE_REQUEST
            // Reset error flag and status code
            error := FALSE;
            status := 16#0000;

            // Check for product storage request
            IF requestIn THEN
                IF libFreeNum > 0 THEN
                    state := 2; // Transition to store product
                ELSE
                    error := TRUE;
                    status := errFull; // Set full storage error
                    state := 4; // Transition to error handling
                END_IF;
            END_IF;

            // Check for product retrieval request
            IF requestOut THEN
                IF productNum > 0 THEN
                    state := 3; // Transition to retrieve product
                ELSE
                    error := TRUE;
                    status := errEmpty; // Set empty storage error
                    state := 4; // Transition to error handling
                END_IF;
            END_IF;

        2: // STORE_PRODUCT
            // Search for free position from highest to lowest index
            found := FALSE;
            FOR i := 9 TO 1 BY -1 DO
                IF NOT library[i] THEN
                    library[i] := TRUE; // Mark position as occupied
                    productNum := productNum + 1; // Increment product count
                    libFreeNum := libFreeNum - 1; // Decrement free space count
                    found := TRUE; // Position found
                    EXIT; // Exit loop once position is found
                END_IF;
            END_FOR;

            // If no position found, set error
            IF NOT found THEN
                error := TRUE;
                status := errFull; // Set full storage error
            END_IF;

            state := 1; // Transition back to handle requests

        3: // RETRIEVE_PRODUCT
            // Search for occupied position from lowest to highest index
            found := FALSE;
            FOR i := 1 TO 9 DO
                IF library[i] THEN
                    library[i] := FALSE; // Mark position as free
                    productNum := productNum - 1; // Decrement product count
                    libFreeNum := libFreeNum + 1; // Increment free space count
                    found := TRUE; // Position found
                    EXIT; // Exit loop once position is found
                END_IF;
            END_FOR;

            // If no position found, set error
            IF NOT found THEN
                error := TRUE;
                status := errEmpty; // Set empty storage error
            END_IF;

            state := 1; // Transition back to handle requests

        4: // ERROR_HANDLING
            // Handle error and reset status
            // No additional actions needed, just transition back
            state := 1; // Transition back to handle requests
    END_CASE;
END_WHILE

END_FUNCTION_BLOCK
END_ST