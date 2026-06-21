FUNCTION_BLOCK FB_SignalControl
VAR_INPUT
    (* Boolean control inputs *)
    Int1 : BOOL;
    Int2 : BOOL;
    Int3 : BOOL;
    Int4 : BOOL;
    Int5 : BOOL;
    Int6 : BOOL;
    Int7 : BOOL;
    Int8 : BOOL;
    
    (* Analog/Threshold inputs *)
    IntAn1 : UINT;
    IntAn2 : UINT;
    IntAn3 : UINT;
    IntAn4 : UINT;
    IntAn5 : UINT;
    IntAn6 : UINT;
    IntAn7 : UINT;
    IntAn8 : UINT;
    
    (* Auxiliary control flag - external input *)
    Marca2_Ext : BOOL;
END_VAR

VAR_OUTPUT
    (* Boolean outputs *)
    Out1 : BOOL;
    Out2 : BOOL;
    Out3 : BOOL;
    Out4 : BOOL;
    Out5 : BOOL;
    Out6 : BOOL;
    Out7 : BOOL;
    Out8 : BOOL;
    
    (* Analog/Threshold outputs *)
    OutAn1 : UINT;
    OutAn2 : UINT;
    OutAn3 : UINT;
    OutAn4 : UINT;
    OutAn5 : UINT;
    OutAn6 : UINT;
    OutAn7 : UINT;
    OutAn8 : UINT;
END_VAR

VAR
    (* Internal flags for latching mechanism *)
    Marca1 : BOOL;
    Marca2_Int : BOOL;
    
    (* Internal variables for conditional logic *)
    GT51_OUT : BOOL;
    GT56_OUT : BOOL;
    GT57_OUT : BOOL;
    GT62_OUT : BOOL;
END_VAR

(* Main execution logic *)
(* Step 1: Calculate internal Marca2 based on external input and internal logic *)
(* The external Marca2_Ext input overrides the internal calculation when TRUE *)
IF Marca2_Ext THEN
    Marca2_Int := TRUE;
ELSE
    (* Internal Marca2 logic as per specification *)
    Marca2_Int := (NOT Marca1 AND Int1 AND (Marca2_Int OR Out1));
END_IF;

(* Step 2: Calculate Marca1 flag *)
Marca1 := (NOT Marca2_Int AND Int1 AND (Marca1 OR NOT Out1));

(* Step 3: Calculate Out1 based on Marca1 and Marca2 *)
Out1 := (NOT Marca2_Int AND (Marca1 OR Out1));

(* Step 4: Direct Boolean pass-through *)
Out2 := Int2;
Out3 := Int3;
Out4 := Int4;

(* Step 5: Direct unsigned integer pass-through *)
OutAn1 := IntAn1;
OutAn2 := IntAn2;
OutAn3 := IntAn3;
OutAn4 := IntAn4;

(* Step 6: Conditional outputs for Out5 to Out8 *)
Out5 := (IntAn5 > 1000) AND NOT Int5;
Out6 := (IntAn6 > 1000) AND NOT Int6;
Out7 := (IntAn7 > 1000) AND NOT Int7;
Out8 := (IntAn8 > 1000) AND NOT Int8;

(* Step 7: Pass through remaining analog outputs *)
OutAn5 := IntAn5;
OutAn6 := IntAn6;
OutAn7 := IntAn7;
OutAn8 := IntAn8;

(* Internal comparison variables for monitoring/debugging *)
GT51_OUT := (IntAn5 > 1000);
GT56_OUT := (IntAn6 > 1000);
GT57_OUT := (IntAn7 > 1000);
GT62_OUT := (IntAn8 > 1000);

END_FUNCTION_BLOCK