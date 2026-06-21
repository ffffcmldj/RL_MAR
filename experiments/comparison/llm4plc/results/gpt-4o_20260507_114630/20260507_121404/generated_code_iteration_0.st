plaintext
START_ST

FUNCTION_BLOCK FB_Fibonacci_Calculator
VAR_INPUT
    N : DINT := 5; // Input term of the Fibonacci sequence to calculate (default is 5)
END_VAR
VAR_OUTPUT
    O : DINT := 1; // Output Fibonacci value
END_VAR
VAR
    F1 : DINT := 1; // (n-2)-th Fibonacci number
    F2 : DINT := 1; // (n-1)-th Fibonacci number
    CNT : DINT := 2; // Counter for current Fibonacci term
    MAX_VALUE : DINT := 32767; // Maximum value for saturation arithmetic
    state : INT := 0; // State variable for FSM
    Next_Fib : DINT := 0; // Temporary variable to store the next Fibonacci number
END_VAR

// Finite State Machine
CASE state OF

    // STATE 0: INITIALIZE
    0:
        F1 := 1;
        F2 := 1;
        CNT := 2;
        IF N <= 2 THEN
            O := 1; // For N <= 2, Fibonacci value is always 1
            state := 2; // Transition to STATE 2 (output result)
        ELSE
            state := 1; // Transition to STATE 1 (calculate Fibonacci)
        END_IF;

    // STATE 1: CALCULATE FIBONACCI
    1:
        Next_Fib := F1 + F2; // Calculate the next Fibonacci number
        IF Next_Fib > MAX_VALUE THEN
            O := MAX_VALUE; // Apply saturation arithmetic
            state := 2; // Transition to STATE 2 (output result)
        ELSE
            F1 := F2; // Update F1 to the previous F2
            F2 := Next_Fib; // Update F2 to the new Fibonacci number
            CNT := CNT + 1; // Increment the counter
            IF CNT >= N THEN
                O := F2; // Set the output to the NN-th Fibonacci number
                state := 2; // Transition to STATE 2 (output result)
            END_IF;
        END_IF;

    // STATE 2: OUTPUT RESULT
    2:
        // Final Fibonacci value is stored in O
        // No further transitions (end of operation)

END_CASE;

END_FUNCTION_BLOCK

PROGRAM Main
VAR
    Fibonacci_Calculator : FB_Fibonacci_Calculator; // Instance of the Fibonacci calculator function block
    NN : DINT := 5; // Input term for Fibonacci sequence (default is 5)
    Fibonacci_Result : DINT; // Variable to store the result
END_VAR

// Main program logic
Fibonacci_Calculator(N := NN); // Call the function block with input NN
Fibonacci_Result := Fibonacci_Calculator.O; // Retrieve the result from the function block

END_PROGRAM

END_ST