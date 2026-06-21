(*
    FUNCTION_BLOCK: FB_Fibonacci_Calculator
    Description: Calculates the N-th Fibonacci number with saturation arithmetic.
    If the calculated value exceeds 32767, the output is saturated at 32767.
    For N <= 2, the output is 1.
    Input: N (DINT) - The term index to calculate (default 5).
    Output: O (DINT) - The calculated Fibonacci number, saturated at 32767 if necessary.
*)

FUNCTION_BLOCK FB_Fibonacci_Calculator
VAR_INPUT
    N : DINT := 5;
END_VAR
VAR_OUTPUT
    O : DINT := 1;
END_VAR
VAR
    F1 : DINT := 1;
    F2 : DINT := 1;
    Cnt : DINT := 2;
    Temp : DINT := 0;
END_VAR

// Main Logic
IF N <= 2 THEN
    O := 1;
    F1 := 1;
    F2 := 1;
    Cnt := 2;
ELSE
    F1 := 1;
    F2 := 1;
    O := 1; // Default for N=1 or N=2, but N>2 so will be overwritten.
    Cnt := 2;
    
    WHILE (Cnt < N) DO
        // Calculate next Fibonacci number
        Temp := F1 + F2;
        
        // Apply saturation arithmetic: cap at 32767
        IF Temp > 32767 THEN
            Temp := 32767;
        END_IF;
        
        // Shift values for next iteration
        F1 := F2;
        F2 := Temp;
        
        // Update output and counter
        O := Temp;
        Cnt := Cnt + 1;
        
        // Exit loop if saturation limit reached
        IF Temp = 32767 THEN
            EXIT;
        END_IF;
    END_WHILE;
END_IF;

END_FUNCTION_BLOCK