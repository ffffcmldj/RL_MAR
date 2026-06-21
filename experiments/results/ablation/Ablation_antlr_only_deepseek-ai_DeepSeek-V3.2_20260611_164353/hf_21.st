(*
FB_SplitNumber
Purpose: Separates a four-digit integer (0-9999) into individual digits and finds the minimum non-zero digit value.
Author: Senior PLC Commissioning Engineer
Date: 2024-06-15
*)

FUNCTION_BLOCK FB_SplitNumber
VAR_INPUT
    InputNumber : INT; (* Input integer value, valid range: 0 to 9999 *)
END_VAR

VAR_OUTPUT
    Thousands : INT; (* Thousands place digit (0-9) *)
    Hundreds : INT;  (* Hundreds place digit (0-9) *)
    Tens : INT;      (* Tens place digit (0-9) *)
    Ones : INT;      (* Ones place digit (0-9) *)
    Min : INT;       (* Minimum non-zero digit among all separated digits *)
    error : BOOL;    (* Error state indicator: TRUE = Input validation failed *)
    status : WORD;   (* Error code: 16#8001 = Input out of range, 16#0000 = No error *)
END_VAR

VAR
    tempNumber : INT; (* Temporary variable for remainder calculations *)
    minValue : INT;   (* Temporary variable for minimum value tracking *)
END_VAR

(* Main execution logic *)
IF (InputNumber < 0) OR (InputNumber > 9999) THEN
    (* Error condition: Input out of valid range *)
    error := TRUE;
    status := 16#8001;
    
    (* Reset all outputs to zero *)
    Thousands := 0;
    Hundreds := 0;
    Tens := 0;
    Ones := 0;
    Min := 0;
ELSE
    (* Valid input condition *)
    error := FALSE;
    status := 16#0000;
    
    (* Digit Separation Phase *)
    (* Extract thousands digit using integer division *)
    Thousands := InputNumber / 1000;
    
    (* Calculate remainder after removing thousands *)
    tempNumber := InputNumber MOD 1000;
    
    (* Extract hundreds digit *)
    Hundreds := tempNumber / 100;
    
    (* Calculate remainder after removing hundreds *)
    tempNumber := tempNumber MOD 100;
    
    (* Extract tens digit *)
    Tens := tempNumber / 10;
    
    (* Extract ones digit (remainder after removing tens) *)
    Ones := tempNumber MOD 10;
    
    (* Minimum Non-Zero Digit Detection Phase *)
    (* Initialize with maximum possible INT value *)
    minValue := 32767;
    
    (* Process thousands digit if non-zero *)
    IF Thousands > 0 THEN
        minValue := minimal(minValue, Thousands);
    END_IF;
    
    (* Process hundreds digit if non-zero *)
    IF Hundreds > 0 THEN
        minValue := minimal(minValue, Hundreds);
    END_IF;
    
    (* Process tens digit if non-zero *)
    IF Tens > 0 THEN
        minValue := minimal(minValue, Tens);
    END_IF;
    
    (* Process ones digit if non-zero *)
    IF Ones > 0 THEN
        minValue := minimal(minValue, Ones);
    END_IF;
    
    (* Determine final Min output *)
    IF minValue = 32767 THEN
        (* All digits were zero *)
        Min := 0;
    ELSE
        (* Found at least one non-zero digit *)
        Min := minValue;
    END_IF;
END_IF;

END_FUNCTION_BLOCK