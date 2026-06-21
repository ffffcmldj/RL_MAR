START_ST
FUNCTION_BLOCK StackMin
VAR_INPUT
    push : BOOL;
    pop : BOOL;
    reset : BOOL;
END_VAR
VAR_OUTPUT
    error : BOOL;
    status : WORD;
END_VAR
VAR_IN_OUT
    item : INT;
    stack : ARRAY[0..3] OF INT;
END_VAR
VAR
    top : INT := -1; // Tracks the index of the top element; -1 means empty
    state : INT := 0; // FSM State Variable (0: Idle, 1: Push, 2: Pop)
    push_active : BOOL; // Flag to track if push was requested this cycle
    pop_active : BOOL; // Flag to track if pop was requested this cycle
    reset_active : BOOL; // Flag to track if reset was requested this cycle
    min_index : INT; // Temporary variable to store index of minimum value
    temp_stack_item : INT; // Temporary variable to hold value during shift
    error_flag : BOOL; // Local error flag to determine final error output
    status_code : WORD; // Local status code to determine final status output
END_VAR

// --- State Machine Logic ---

// Reset Logic: Process immediately if triggered, then transition to Idle
IF reset = TRUE THEN
    reset_active := TRUE;
    top := -1;
    error_flag := FALSE;
    status_code := 16#0000;
    state := 0;
ELSIF push = TRUE AND pop = FALSE THEN
    push_active := TRUE;
    pop_active := FALSE;
    reset_active := FALSE;
    // Transition to Push Operation
    state := 1;
ELSIF push = FALSE AND pop = TRUE THEN
    push_active := FALSE;
    pop_active := TRUE;
    reset_active := FALSE;
    // Transition to Pop Operation
    state := 2;
ELSE
    // Idle State (No active operation or both false)
    push_active := FALSE;
    pop_active := FALSE;
    reset_active := FALSE;
    state := 0;
END_IF

// --- State 0: IDLE (No active operation) ---
IF state = 0 THEN
    error_flag := FALSE;
    status_code := 16#0000;
    // No modification to stack or top occurs here unless reset was handled above
END_IF

// --- State 1: PUSH_OPERATION ---
IF state = 1 THEN
    IF top = 3 THEN
        // Stack is full
        error_flag := TRUE;
        status_code := 16#8A04;
        // Do not modify stack or top
    ELSE
        // Stack not full, perform push
        top := top + 1;
        stack[top] := item;
        error_flag := FALSE;
        status_code := 16#0000;
    END_IF;
    // Transition back to Idle after operation
    state := 0;
END_IF

// --- State 2: POP_OPERATION ---
IF state = 2 THEN
    IF top = -1 THEN
        // Stack is empty
        error_flag := TRUE;
        status_code := 16#8A05;
        // Do not modify stack or top
    ELSE
        // Stack not empty, find minimum
        min_index := 0;
        FOR i := 1 TO top DO
            IF stack[i] < stack[min_index] THEN
                min_index := i;
            END_IF;
        END_FOR;

        // Store minimum value in item
        item := stack[min_index];

        // Shift elements above min_index down by one position
        FOR i := min_index TO top - 1 DO
            stack[i] := stack[i + 1];
        END_FOR;

        // Decrement top
        top := top - 1;

        error_flag := FALSE;
        status_code := 16#0000;
    END_IF;
    // Transition back to Idle after operation
    state := 0;
END_IF

// Assign final outputs
error := error_flag;
status := status_code;

END_FUNCTION_BLOCK
END_ST