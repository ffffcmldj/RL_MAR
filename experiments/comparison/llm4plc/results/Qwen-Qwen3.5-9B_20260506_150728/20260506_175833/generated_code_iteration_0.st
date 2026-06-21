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
    isInitialized : BOOL; (* Flag to ensure initialization happens only once *)
    LockerStatus : ARRAY[1..10] OF BOOL; (* Status of individual lockers: TRUE=locked, FALSE=empty *)
    LockerAccessCode : ARRAY[1..10] OF INT; (* Locker access codes *)
    i : INT; (* Loop counter for initialization *)
    tempCode : INT; (* Temporary variable to hold input code for comparison *)
END_VAR

(* --- Initialization Logic --- *)
(* Check if this is the first scan or if variables have been reset. 
   We use a static-like approach by checking if the first code is still the default 0 
   or if the status array is all FALSE (though default is TRUE). 
   A robust way in ST without RETAIN keyword on the FB itself is to check a specific marker.
   However, per the plan's requirement to initialize within the block, we assume 
   the FB instance might be re-instantiated or we need a one-time flag.
   Since 'isInitialized' is a local VAR, it resets to FALSE every scan unless declared RETAIN.
   The prompt implies standard VAR. To make this work as a one-time init in a standard FB 
   without external RETAIN, we must rely on the fact that if the FB is called, 
   we can check if the arrays are in their 'default' state or use a specific marker.
   
   *Correction based on strict IEC 61131-3 and Plan*: 
   The plan suggests using `isInitialized`. In a standard FB, local variables reset every cycle.
   To satisfy "Initialize... within the function block" and "Initially all lockers TRUE",
   we will implement the initialization logic inside the block. 
   If the FB is called in a program where it retains state (via RETAIN on the FB instance in the project), 
   `isInitialized` would need to be RETAIN. 
   However, if we cannot use RETAIN on the variable, we must assume the FB is called once or 
   we implement a check based on the array content.
   
   *Refined Approach per Plan Note*: The plan note says "if the arrays are currently empty or using a static flag".
   Since we cannot declare `RETAIN` on `isInitialized` inside the VAR section without it being a global/static property 
   of the FB instance (which depends on the PLC project configuration), we will assume the standard behavior 
   where we perform the check. 
   
   *Crucial Implementation Detail*: To ensure initialization happens only once in a standard FB call:
   We will check if `LockerAccessCode[1]` is equal to 0 (default integer value). 
   If it is 0, we initialize. If it is not 0, we assume it was already initialized.
   This avoids the need for a separate RETAIN variable if the project doesn't support it, 
   but strictly speaking, for a persistent "Initialized" flag, `isInitialized` should be RETAIN.
   Given the imperative to follow the plan and standard ST, we will declare `isInitialized` as a standard BOOL.
   To make the logic robust as per the "Plan Note", we will combine the check:
   If `isInitialized` is FALSE (first scan) OR `LockerAccessCode[1]` is 0 (reset occurred), we init.
   Actually, the simplest interpretation of "Initialize within the function block" for a one-time setup 
   in a standard environment is to rely on the first execution or a specific condition.
   
   Let's follow the Plan's explicit logic:
   "Check `isInitialized`. If FALSE, set all... Set `isInitialized` to TRUE."
   Since `isInitialized` is local, it is FALSE every scan. This would cause infinite initialization loops 
   unless the FB is configured with RETAIN in the project or we use the array content check.
   
   *Decision*: We will implement the initialization logic that runs if the first code is 0 (uninitialized state).
   This ensures it runs once per instance lifecycle if the instance is recreated, or we assume the user 
   will handle the RETAIN attribute in the project configuration. 
   However, to strictly follow the "Plan" text which defines `isInitialized`, we will use it.
   We will assume the FB instance has the RETAIN property enabled in the project for this logic to hold, 
   OR we implement the check `LockerAccessCode[1] = 0` as the trigger for initialization if `isInitialized` is not RETAIN.
   
   *Revised Logic for Robustness*:
   IF (isInitialized = FALSE) OR (LockerAccessCode[1] = 0) THEN
       (* Perform Initialization *)
       isInitialized := TRUE;
       (* Set Status to Locked (TRUE) *)
       FOR i := 1 TO 10 DO
           LockerStatus[i] := TRUE;
       END_FOR;
       (* Set Codes *)
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
(* Only proceed with logic if initialized *)
IF isInitialized = TRUE THEN
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
            (* Invalid number, stay in State 1 or go to 0? Plan says "Stay in State 1" implies waiting for retry 
            or "Reset to check number again". Plan: "STATE 1 -> STATE 0: IF Invalid". 
            Let's follow Plan: Invalid -> State 0 (Idle/Reset). 
            Actually, Plan says: "STATE 1 -> STATE 0: IF (LockerNumber < 1) OR (LockerNumber > 10)".
            So we go back to 0. *)
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
            (* Code mismatch, Plan says: "STATE 2 -> STATE 1". 
            Reset to check number again. *)
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
        (* Plan: "STATE 4 -> STATE 1: Always (On next scan, reset to allow new input)" *)
        state := 1;
    END_IF;
END_IF;

END_FUNCTION_BLOCK
END_ST