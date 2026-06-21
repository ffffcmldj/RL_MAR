START_ST
FUNCTION_BLOCK FB_SignalControl
VAR_INPUT
    Int1 : BOOL;
    Int2 : BOOL;
    Int3 : BOOL;
    Int4 : BOOL;
    Int5 : BOOL;
    Int6 : BOOL;
    Int7 : BOOL;
    Int8 : BOOL;
    IntAn1 : UINT;
    IntAn2 : UINT;
    IntAn3 : UINT;
    IntAn4 : UINT;
    IntAn5 : UINT;
    IntAn6 : UINT;
    IntAn7 : UINT;
    IntAn8 : UINT;
    Marca2 : BOOL;
END_VAR

VAR_OUTPUT
    Out1 : BOOL;
    Out2 : BOOL;
    Out3 : BOOL;
    Out4 : BOOL;
    Out5 : BOOL;
    Out6 : BOOL;
    Out7 : BOOL;
    Out8 : BOOL;
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
    Marca1 : BOOL;
    GT51_OUT : BOOL;
    GT56_OUT : BOOL;
    GT57_OUT : BOOL;
    GT62_OUT : BOOL;
END_VAR
END_VAR

    (* STATE 0: INITIALIZE / RESET *)
    (* Initialize Marca1 to FALSE at the start of the scan cycle *)
    Marca1 := FALSE;

    (* STATE 1: UPDATE FLAGS (MARCA1 & MARCA2) *)
    (* Calculate Marca1_New: (NOT Marca2) AND (Marca1 OR Out1) AND Int1 *)
    Marca1 := (NOT Marca2) AND (Marca1 OR Out1) AND Int1;
    
    (* Calculate Marca2_New: (NOT Marca1) AND (Marca2 OR Out1) AND Int1 *)
    (* Note: Using the newly calculated Marca1 for this step as per sequential logic flow *)
    Marca2 := (NOT Marca1) AND (Marca2 OR Out1) AND Int1;

    (* STATE 2: UPDATE LATCHED OUTPUT (OUT1) *)
    (* Logic: Out1 is TRUE if: (NOT Marca2) AND (Marca1 OR Out1) *)
    (* Else Out1 is FALSE *)
    Out1 := (NOT Marca2) AND (Marca1 OR Out1);

    (* STATE 3: DIRECT PASS-THROUGH (BOOL & UINT) *)
    Out2 := Int2;
    Out3 := Int3;
    Out4 := Int4;
    OutAn1 := IntAn1;
    OutAn2 := IntAn2;
    OutAn3 := IntAn3;
    OutAn4 := IntAn4;

    (* STATE 4: CONDITIONAL OUTPUT LOGIC (OUT5-OUT8) *)
    (* Condition for Out5: IntAn5 > 1000 AND Int5 is FALSE *)
    GT51_OUT := (IntAn5 > 1000) AND (NOT Int5);
    Out5 := GT51_OUT;

    (* Condition for Out6: IntAn6 > 1000 AND Int6 is FALSE *)
    GT56_OUT := (IntAn6 > 1000) AND (NOT Int6);
    Out6 := GT56_OUT;

    (* Condition for Out7: IntAn7 > 1000 AND Int7 is FALSE *)
    GT57_OUT := (IntAn7 > 1000) AND (NOT Int7);
    Out7 := GT57_OUT;

    (* Condition for Out8: IntAn8 > 1000 AND Int8 is FALSE *)
    GT62_OUT := (IntAn8 > 1000) AND (NOT Int8);
    Out8 := GT62_OUT;

END_ST