START_REASON
The CODESYS compiler error "CASE标号要求文字或符号整型常量" translates to "CASE label requires a literal or symbolic integer constant." This indicates that in the CASE statement, the labels (STATE_IDLE and STATE_MIXING) must be integer constants, but in the current code, they are variables declared in the VAR section. In CODESYS Structured Text, CASE labels must be compile-time constants, not runtime variables. To fix this, I should declare STATE_IDLE and STATE_MIXING as constants using VAR CONSTANT, ensuring they are true constants rather than mutable variables. Additionally, I'll move the MixingTimeLimit declaration to VAR CONSTANT as well since it's a fixed parameter. This will make the CASE statement valid and improve code clarity.
END_REASON

START_ST
FUNCTION_BLOCK DoughMixerControl
VAR_INPUT
    IngredientsDetected : BOOL;
END_VAR
VAR_OUTPUT
    MixingInProgress : BOOL;
END_VAR
VAR
    state : INT;
    prevIngredientsDetected : BOOL;
    MixingTimeElapsed : TIME;
END_VAR
VAR CONSTANT
    MixingTimeLimit : TIME := T#5S;
    STATE_IDLE : INT := 0;
    STATE_MIXING : INT := 1;
END_VAR

(* Main execution logic *)
CASE state OF
    STATE_IDLE:
        (* Output *)
        MixingInProgress := FALSE;
        (* Timer holds value - no increment in IDLE state *)
        (* Check for rising edge to start mixing *)
        IF (IngredientsDetected AND NOT prevIngredientsDetected) THEN
            (* Reset timer and transition to MIXING state *)
            MixingTimeElapsed := T#0S;
            state := STATE_MIXING;
        END_IF;

    STATE_MIXING:
        (* Output *)
        MixingInProgress := TRUE;
        (* Increment timer by 1 second per PLC cycle *)
        MixingTimeElapsed := MixingTimeElapsed + T#1S;
        (* Check transition conditions *)
        IF (MixingTimeElapsed >= MixingTimeLimit) OR (NOT IngredientsDetected) THEN
            state := STATE_IDLE;
        END_IF;
END_CASE;

(* Update edge detection variable for next cycle *)
prevIngredientsDetected := IngredientsDetected;

END_FUNCTION_BLOCK
END_ST