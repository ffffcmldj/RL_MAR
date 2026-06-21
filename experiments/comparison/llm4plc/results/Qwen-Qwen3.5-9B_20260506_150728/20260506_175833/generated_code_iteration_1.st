START_REASON
The previous code failed CODESYS compiler validation (Error 500) primarily due to the use of the `RETAIN` keyword inside the `VAR` section of a `FUNCTION_BLOCK`. In IEC 61131-3, the `RETAIN` keyword is not a valid attribute for variables declared inside the `VAR` or `VAR_INPUT`/`VAR_OUTPUT` sections of a Function Block. Retention is a property of the instance itself, configured in the project configuration (e.g., in TIA Portal or CODESYS), not by writing `RETAIN` next to the variable name in the source code.

Additionally, the logic for initialization relied on a local variable `isInitialized` which resets to `FALSE` on every scan cycle. Without the `RETAIN` keyword (which is syntactically invalid here) or a persistent instance property, the initialization logic would execute every time the FB is called, overwriting the locker codes and status constantly.

To fix this while adhering to standard ST syntax:
1.  Remove the `RETAIN` keyword entirely.
2.  Implement a robust initialization check using the content of the `LockerAccessCode` array. Since `INT` defaults to 0, we can check if `LockerAccessCode[1]` is 0. If it is 0, we assume the instance is uninitialized and perform the setup. If it is non-zero, we assume it is initialized. This works because the array is part of the FB instance's memory, which persists across scans (unlike local `VAR` variables which reset).
3.  Ensure all variable declarations are strictly compliant with IEC 61131-3 (no `RETAIN`, correct types).
4.  Maintain the `FUNCTION_BLOCK` structure and `END_VAR` usage.
END_REASON

START_ST
FUNCTION_BLOCK SmartLockerControl
VAR_INPUT
    AccessCode : INT; (* Input for user access code *)
    LockerNumber : INT; (* Input for selected locker number *)
END_VAR
VAR_OUTPUT
    LockerOpen : BOOL; (* Output to control locker door *)
END_VAR
VAR
    state : INT; (* Current FSM State: 0=Idle, 1=Validating Number, 2=Validating Code, 3=Opening, 4=Opened *)
    LockerStatus : ARRAY[1..10] OF BOOL; (* Status of individual lockers: TRUE=locked, FALSE=empty *)
    LockerAccessCode : ARRAY[1..10] OF INT; (* Locker access codes *)
    i : INT; (* Loop counter for initialization *)
    tempCode : INT; (* Temporary variable to hold input code for comparison *)
END_VAR

(* --- Initialization Logic --- *)
(* Check if the instance is uninitialized. 
   Since INT defaults to 0, if LockerAccessCode[1] is 0, we assume this is the first scan 
   or the instance has been reset. We initialize the arrays only in this case.
   This leverages the persistence of the FB instance variables without needing the RETAIN keyword. *)
IF LockerAccessCode[1] = 0 THEN
    (* Perform Initialization *)
    (* Set Status to Locked (TRUE) *)
    FOR i := 1 TO 10 DO
        LockerStatus[i] := TRUE;
    END_FOR;
    
    (* Set Default Codes *)
    LockerAccessCode[1] := 1234;
    LockerAccessCode[2] := 5678;
    LockerAccessCode[3] := 9876;
    LockerAccessCode[4] := 4321;
    LockerAccessCode[5] := 6543;
    LockerAccessCode[6] := 7890;
    LockerAccessCode[7] := 3456;
    LockerAccessCode[8] := 8765;
    LockerAccessCode[9] := 2345;
    LockerAccessCode[10] := 6789;
END_IF;

(* --- State Machine Logic --- *)
(* Only proceed with logic if the instance is initialized *)
IF LockerAccessCode[1] <> 0 THEN
    (* State 0: IDLE *)
    IF state = 0 THEN
        LockerOpen := FALSE;
        (* Transition to State 1: Validate Number *)
        state := 1;
    END_IF;

    (* State 1: VALIDATING LOCKER NUMBER *)
    IF state = 1 THEN
        LockerOpen := FALSE;
        IF (LockerNumber >= 1) AND (LockerNumber <= 10) THEN
            (* Valid number, move to State 2: Validate Code *)
            state := 2;
        ELSE
            (* Invalid number, reset to State 0 (Idle) *)
            state := 0;
        END_IF;
    END_IF;

    (* State 2: VALIDATING ACCESS CODE *)
    IF state = 2 THEN
        LockerOpen := FALSE;
        tempCode := AccessCode;
        IF tempCode = LockerAccessCode[LockerNumber] THEN
            (* Code matches, move to State 3: Opening *)
            state := 3;
        ELSE
            (* Code mismatch, reset to State 1 (Re-validate Number) *)
            state := 1;
        END_IF;
    END_IF;

    (* State 3: OPENING LOCKER *)
    IF state = 3 THEN
        LockerOpen := TRUE;
        (* Update Status to Empty (FALSE) *)
        LockerStatus[LockerNumber] := FALSE;
        (* Move to State 4: Held Open *)
        state := 4;
    END_IF;

    (* State 4: LOCKER OPENED (Hold) *)
    IF state = 4 THEN
        LockerOpen := TRUE;
        (* Reset to State 1 to allow new input on the next scan *)
        state := 1;
    END_IF;
END_IF;

END_FUNCTION_BLOCK
END_ST