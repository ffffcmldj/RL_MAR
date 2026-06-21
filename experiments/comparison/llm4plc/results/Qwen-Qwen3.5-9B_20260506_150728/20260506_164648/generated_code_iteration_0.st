START_ST
FUNCTION_BLOCK FB_RealValueAdjuster
VAR_INPUT
x_in : REAL;
END_VAR
VAR_OUTPUT
x_out : REAL;
END_VAR
VAR
CurrentState : INT; // FSM State Variable (0-4)
accumulator : REAL; // Holds the sum of 1.0s to add
temp_int : INT; // Integer conversion result
is_zero : BOOL; // Flag for x_in == 0.0
is_non_zero : BOOL; // Flag for x_in <> 0.0
int_val_non_zero : BOOL; // Flag for temp_int <> 0
overflow_detected : BOOL; // Flag for integer conversion overflow
END_VAR

BEGIN
    (* STATE 0: INITIALIZE *)
    (* Read input is automatic via VAR_INPUT. *)
    (* Prepare logic: Initialize accumulator and reset state machine if needed. *)
    (* Since this is a cyclic FB, we increment state at the end of the cycle. *)
    (* However, to strictly follow the plan's state flow per scan: *)
    (* We will use a CASE statement based on CurrentState to execute the specific logic. *)
    (* Note: In a real cyclic scan, CurrentState usually increments at the end. *)
    (* Here, we implement the logic as described in the plan's state transitions. *)

    CASE CurrentState OF
        0: (* STATE 0: INITIALIZE *)
            (* Initialize accumulator to 0.0 *)
            accumulator := 0.0;
            (* Increment state to move to STATE 1 *)
            CurrentState := CurrentState + 1;
            
        1: (* STATE 1: PROCESS_ZERO_CHECK *)
            (* Check if x_in is exactly 0.0 *)
            is_zero := (x_in = 0.0);
            (* Increment state to move to STATE 2 *)
            CurrentState := CurrentState + 1;
            
        2: (* STATE 2: PROCESS_NON_ZERO_CHECK *)
            (* Check if x_in is not 0.0 *)
            is_non_zero := (x_in <> 0.0);
            (* Increment state to move to STATE 3 *)
            CurrentState := CurrentState + 1;
            
        3: (* STATE 3: PROCESS_INTEGER_CONVERSION *)
            (* Convert to INT and check for overflow *)
            (* Check if x_in is within the range of INT to prevent overflow *)
            IF (x_in >= -2147483648.0) AND (x_in <= 2147483647.0) THEN
                temp_int := INT(x_in);
                overflow_detected := FALSE;
            ELSE
                (* Overflow detected or out of range *)
                temp_int := 0; (* Default value, though logic below handles this *)
                overflow_detected := TRUE;
            END_IF;
            
            (* Check if integer conversion result is non-zero *)
            (* If overflow occurred, we treat int_val_non_zero as FALSE per safety requirements *)
            IF NOT overflow_detected AND (temp_int <> 0) THEN
                int_val_non_zero := TRUE;
            ELSE
                int_val_non_zero := FALSE;
            END_IF;
            
            (* Increment state to move to STATE 4 *)
            CurrentState := CurrentState + 1;
            
        4: (* STATE 4: CALCULATE_AND_ASSIGN *)
            (* Apply all additions to accumulator *)
            
            (* Rule: If input is exactly 0.0, add 1.0 *)
            IF is_zero THEN
                accumulator := accumulator + 1.0;
            END_IF;
            
            (* Rule: If input is not 0.0, also add 1.0 *)
            IF is_non_zero THEN
                accumulator := accumulator + 1.0;
            END_IF;
            
            (* Rule: If integer conversion is not zero, add 1.0 *)
            IF int_val_non_zero THEN
                accumulator := accumulator + 1.0;
            END_IF;
            
            (* Assign final result to output *)
            x_out := x_in + accumulator;
            
            (* Reset state to 0 for the next cycle *)
            CurrentState := 0;
            
        ELSE
            (* Safety fallback: Reset state if it goes out of bounds *)
            CurrentState := 0;
        END_CASE;
END_FUNCTION_BLOCK
END_ST