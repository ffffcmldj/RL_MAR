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
    CNT : DINT := 2;
    TempSum : DINT;
END_VAR

(* Handle edge cases: N <= 2 returns 1 *)
IF N <= 2 THEN
    O := 1;
ELSE
    (* Initialize Fibonacci sequence *)
    F1 := 1;
    F2 := 1;
    CNT := 2;
    
    (* Calculate Fibonacci numbers up to N-th term *)
    WHILE CNT < N DO
        TempSum := F1 + F2;
        
        (* Apply saturation arithmetic: clamp at INT maximum (32767) *)
        IF TempSum > 32767 THEN
            F2 := 32767;
            EXIT;  (* Exit loop early when saturation limit reached *)
        END_IF;
        
        (* Update Fibonacci values for next iteration *)
        F1 := F2;
        F2 := TempSum;
        CNT := CNT + 1;
    END_WHILE;
    
    (* Set output to the N-th Fibonacci number *)
    O := F2;
END_IF;
END_FUNCTION_BLOCK