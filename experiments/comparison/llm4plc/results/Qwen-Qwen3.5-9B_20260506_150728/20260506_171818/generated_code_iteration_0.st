START_ST
FUNCTION_BLOCK FB_Fibonacci_Calculator
VAR_INPUT
    N : DINT := 5;
END_VAR
VAR_OUTPUT
    O : DINT := 1;
END_VAR
VAR
    state : INT;
    F1 : DINT := 1;
    F2 : DINT := 1;
    CNT : DINT := 2;
    TEMP_SUM : DINT;
    MAX_INT : DINT := 32767;
END_VAR

BEGIN
    (* STATE 0: INITIALIZE *)
    IF state = 0 THEN
        (* Reset internal counters and variables *)
        F1 := 1;
        F2 := 1;
        CNT := 2;
        
        (* Handle edge cases where N <= 2 *)
        IF N <= 2 THEN
            O := 1;
            (* Transition to STATE 2 immediately to output result *)
            state := 2;
        ELSE
            (* Transition to STATE 1 to calculate sequence *)
            state := 1;
        END_IF;
    END_IF;

    (* STATE 1: CALCULATE_SEQUENCE *)
    IF state = 1 THEN
        (* Loop logic: While CNT < N *)
        WHILE CNT < N DO
            (* Calculate temporary sum *)
            TEMP_SUM := F1 + F2;
            
            (* Apply Saturation Arithmetic Logic *)
            IF TEMP_SUM > MAX_INT THEN
                TEMP_SUM := MAX_INT;
            END_IF;
            
            (* Shift values: F1 becomes F2, F2 becomes new sum *)
            F1 := F2;
            F2 := TEMP_SUM;
            
            (* Increment counter *)
            CNT := CNT + 1;
        END_WHILE;
        
        (* Transition to STATE 2 once calculation is complete *)
        state := 2;
    END_IF;

    (* STATE 2: OUTPUT_RESULT *)
    IF state = 2 THEN
        (* Assign the final calculated value to the output *)
        O := F2;
        
        (* Reset state to 0 for next execution cycle *)
        state := 0;
    END_IF;
END_FUNCTION_BLOCK
END_ST