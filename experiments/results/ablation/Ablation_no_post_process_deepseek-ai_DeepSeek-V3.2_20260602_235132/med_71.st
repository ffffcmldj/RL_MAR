(*
    Fibonacci Calculator Function Block with Saturation Arithmetic
    Author: Senior PLC Commissioning Engineer
    Description: Calculates the N-th Fibonacci number with saturation at 32767
    Compliance: IEC 61131-3 Structured Text
*)

TYPE
    eFibonacciStatus : (
        eStatus_OK := 0,
        eStatus_Saturated := 1
    );
END_TYPE

FUNCTION_BLOCK FB_Fibonacci_Calculator
VAR_INPUT
    N : DINT := 5;  (* Target term index, 1-based *)
END_VAR
VAR_OUTPUT
    O : DINT := 1;  (* Calculated Fibonacci number *)
    Status : eFibonacciStatus := eStatus_OK;  (* Calculation status *)
END_VAR
VAR
    F1 : DINT := 1;  (* First previous term *)
    F2 : DINT := 1;  (* Second previous term *)
    Cnt : DINT := 2;  (* Current iteration counter *)
    Temp : DINT := 0;  (* Temporary variable for calculation *)
    MaxInt : DINT := 32767;  (* Maximum allowed value for saturation *)
END_VAR

(* Main calculation logic *)
IF N <= 0 THEN
    (* Invalid input - return 1 as specified for edge cases *)
    O := 1;
    Status := eStatus_OK;
ELSIF N <= 2 THEN
    (* Base cases: F(1) = 1, F(2) = 1 *)
    O := 1;
    Status := eStatus_OK;
ELSE
    (* Initialize for iterative calculation *)
    F1 := 1;
    F2 := 1;
    Cnt := 2;
    Status := eStatus_OK;
    
    (* Iterative calculation of Fibonacci numbers *)
    WHILE Cnt < N AND Status = eStatus_OK DO
        (* Check for potential overflow before calculation *)
        IF (F1 > MaxInt - F2) THEN
            (* Saturation condition detected *)
            O := MaxInt;
            Status := eStatus_Saturated;
        ELSE
            (* Calculate next Fibonacci number *)
            Temp := F1 + F2;
            
            (* Update previous terms for next iteration *)
            F1 := F2;
            F2 := Temp;
            
            (* Update counter *)
            Cnt := Cnt + 1;
            
            (* Set output to current term *)
            O := Temp;
        END_IF;
    END_WHILE;
END_IF;

END_FUNCTION_BLOCK;