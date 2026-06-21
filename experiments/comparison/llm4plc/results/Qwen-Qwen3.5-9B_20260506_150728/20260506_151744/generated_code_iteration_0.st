START_ST
FUNCTION_BLOCK RandomNumberGenerator
VAR_INPUT
    minValue : DINT;
    maxValue : DINT;
    randomSeed_in : DINT;
END_VAR
VAR_OUTPUT
    error : BOOL;
    status : WORD;
    randomNumber : DINT;
END_VAR
VAR
    currentState : INT;
    tempRange : DINT;
    absSeed : DINT;
    modResult : DINT;
END_VAR

// STATE 0: INITIALIZE (Input Validation)
IF currentState = 0 THEN
    // Check if the range is valid
    IF minValue > maxValue THEN
        error := TRUE;
        status := 16#8200;
        randomNumber := 0; // Reset output on error
    ELSE
        // Transition to State 1
        currentState := 1;
    END_IF;
END_IF;

// STATE 1: GENERATE_RANDOM_NUMBER (Calculation)
IF currentState = 1 THEN
    // Ensure seed is positive
    absSeed := ABS(randomSeed_in);
    
    // Calculate the range size
    tempRange := maxValue - minValue + 1;
    
    // Perform modulo operation to get random offset
    modResult := absSeed MOD tempRange;
    
    // Calculate final random number
    randomNumber := modResult + minValue;
    
    // Set success status
    error := FALSE;
    status := 16#0000;
    
    // Reset state for next execution (optional, depending on if seed updates externally)
    // Keeping state at 1 allows re-calculation if inputs change in same scan, 
    // but typically FSM resets to 0 after one cycle or stays if continuous.
    // Based on plan "State 0 -> State 1", we reset to 0 after generation to prevent re-triggering logic in same cycle
    // unless inputs change. However, standard FB behavior often re-evaluates every cycle.
    // To strictly follow the FSM plan provided:
    currentState := 0;
END_IF;

END_FUNCTION_BLOCK
END_ST