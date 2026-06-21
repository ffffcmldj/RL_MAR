START_REASON
The validation feedback from CODESYS indicates a syntax error: "应该用';' 替换'MaxSalinity'" (Should replace 'MaxSalinity' with ';').

This error occurs in the `VAR` section where `MaxSalinity` is declared with an initialization value:
`MaxSalinity : REAL := 35.0;`

In IEC 61131-3 Structured Text (ST), specifically within the `VAR` section of a Function Block (FB), **initialization values are not allowed** for variables declared there. Initialization is only permitted in:
1.  The `VAR_INPUT` section (though typically inputs are passed by reference or value without explicit initialization in the declaration line in some compilers, but definitely not in VAR).
2.  The `VAR_OUTPUT` section.
3.  The `VAR` section using the `INIT` keyword (e.g., `MaxSalinity : REAL INIT := 35.0;`), but standard CodeSYS compilers often prefer or require the initialization to happen in the `BEGIN` block or use the `INIT` keyword explicitly if supported. However, the most common and portable way to fix this specific "replace with ;" error is to remove the `:= 35.0` part from the declaration and assign the value inside the `BEGIN` block.

Additionally, looking at the logic:
- The `MaxSalinity` is re-assigned in the `BEGIN` block (`MaxSalinity := 35.0;`). Since it was declared without initialization, this assignment is valid.
- The `TimerInterval` is also declared with `:= 10`. This should also be moved to the `BEGIN` block or initialized properly if the compiler is strict, but usually constants in `VAR` don't need initialization if they are just integers. However, to be safe and consistent with the error pattern, I will move all initializations to the `BEGIN` block.

The logic flow seems generally correct for a state machine, but the syntax regarding variable initialization in the `VAR` section is the primary blocker.

Fixes applied:
1.  Removed `:= 35.0` from `MaxSalinity` declaration in `VAR`.
2.  Removed `:= 10` from `TimerInterval` declaration in `VAR`.
3.  Moved the initialization of `MaxSalinity` and `TimerInterval` into the `BEGIN` block immediately after the `(* --- Initialization --- *)` comment.
4.  Ensured all variable sections are closed with `END_VAR`.
5.  Ensured the function block is closed with `END_FUNCTION_BLOCK`.

END_REASON

START_ST
FUNCTION_BLOCK WaterDesalination
VAR_INPUT
    StartButton : BOOL;
    StopButton : BOOL;
    SalinitySensor : REAL;
END_VAR
VAR_OUTPUT
    SeawaterInletValve : BOOL;
    FreshwaterOutletValve : BOOL;
    DesalinationInProgress : BOOL;
END_VAR
VAR
    (* State Machine Variables *)
    currentState : INT; (* 0: IDLE, 1: RUNNING, 2: SALINITY_HIGH *)
    
    (* Timer Variables for 10-second interval *)
    salinityTimer : INT; (* Accumulates scan cycles or time units up to 10 *)
    (* Note: In a real implementation, this would typically be driven by a TON timer block
       where PT = T#10s. Here we simulate the logic flow assuming the timer increments
       by 1 every scan cycle for demonstration of the state logic. *)
    
    (* Constants *)
    MaxSalinity : REAL;
    TimerInterval : INT;
END_VAR

BEGIN
    (* --- Initialization --- *)
    MaxSalinity := 35.0;
    TimerInterval := 10;
    
    (* --- State Machine Logic --- *)
    
    (* Transition: IDLE (0) -> RUNNING (1) *)
    (* Condition: StartButton pressed AND currently not in progress *)
    IF (StartButton = TRUE) AND (DesalinationInProgress = FALSE) THEN
        currentState := 1;
        salinityTimer := 0; (* Reset timer on start *)
    END_IF;

    (* Transition: RUNNING (1) -> SALINITY_HIGH (2) *)
    (* Condition: Currently running AND salinity is too high *)
    IF (currentState = 1) AND (SalinitySensor > MaxSalinity) THEN
        currentState := 2;
    END_IF;

    (* Transition: SALINITY_HIGH (2) -> RUNNING (1) *)
    (* Condition: Currently in high salinity state AND salinity is acceptable *)
    IF (currentState = 2) AND (SalinitySensor <= MaxSalinity) THEN
        currentState := 1;
    END_IF;

    (* Transition: RUNNING (1) -> IDLE (0) *)
    (* Condition: StopButton pressed *)
    IF (StopButton = TRUE) THEN
        currentState := 0;
        salinityTimer := 0;
    END_IF;

    (* Transition: SALINITY_HIGH (2) -> IDLE (0) *)
    (* Condition: StopButton pressed *)
    IF (currentState = 2) AND (StopButton = TRUE) THEN
        currentState := 0;
        salinityTimer := 0;
    END_IF;

    (* --- Timer Logic for 10-second Interval --- *)
    (* Increment timer every scan cycle *)
    salinityTimer := salinityTimer + 1;

    (* Check if 10 seconds have elapsed *)
    IF salinityTimer >= TimerInterval THEN
        salinityTimer := 0; (* Reset timer for next interval *)
        
        (* Perform Salinity Check *)
        IF SalinitySensor > MaxSalinity THEN
            (* Force state to SALINITY_HIGH if not already there *)
            IF currentState <> 2 THEN
                currentState := 2;
            END_IF;
        ELSE
            (* Force state to RUNNING if salinity is good *)
            IF currentState <> 1 THEN
                currentState := 1;
            END_IF;
        END_IF;
    END_IF;

    (* --- Output Assignment Based on State --- *)
    
    CASE currentState OF
        0: (* IDLE *)
            SeawaterInletValve := FALSE;
            FreshwaterOutletValve := FALSE;
            DesalinationInProgress := FALSE;
            
        1: (* RUNNING *)
            SeawaterInletValve := TRUE;
            FreshwaterOutletValve := TRUE;
            DesalinationInProgress := TRUE;
            
        2: (* SALINITY_HIGH *)
            SeawaterInletValve := TRUE;
            FreshwaterOutletValve := FALSE;
            DesalinationInProgress := TRUE;
    END_CASE;

END_FUNCTION_BLOCK
END_ST