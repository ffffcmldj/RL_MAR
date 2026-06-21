START_REASON
The previous code failed with the error "未知的类型: 'T_TheaterState'" (Unknown type: 'T_TheaterState').

**Root Cause Analysis:**
In IEC 61131-3 Structured Text, `TYPE` definitions must be placed in the **global scope** (outside of any function, function block, or program) to be accessible by other blocks. The previous code attempted to define the `TYPE` inside the `FUNCTION_BLOCK` body, which is syntactically invalid. The compiler could not resolve the type `T_TheaterState` because it was declared locally where it was not allowed.

**Fix Strategy:**
1.  Move the `TYPE T_TheaterState` definition to the global scope, before the `FUNCTION_BLOCK` declaration.
2.  Ensure the `FUNCTION_BLOCK` uses the global type correctly.
3.  Maintain the `FUNCTION_BLOCK` structure and `END_VAR` usage as required.
END_REASON

START_ST
TYPE T_TheaterState :
    IDLE := 0,
    RUNNING := 1,
    STOPPED := 2
END_TYPE;

FUNCTION_BLOCK TheaterControl
VAR_INPUT
    StartButton : BOOL;
    StopButton : BOOL;
    SceneNumber : INT;
END_VAR
VAR_OUTPUT
    LightingControl : BOOL;
    SoundControl : BOOL;
    PerformanceInProgress : BOOL;
END_VAR
VAR
    state : T_TheaterState;
    prevStartButton : BOOL;
    prevStopButton : BOOL;
    isValidScene : BOOL;
END_VAR

BEGIN
    (* --- Step 1: Validate Scene Number --- *)
    IF (SceneNumber >= 1) AND (SceneNumber <= 3) THEN
        isValidScene := TRUE;
    ELSE
        isValidScene := FALSE;
    END_IF;

    (* --- Step 2: State Machine Logic --- *)

    CASE state OF
        IDLE:
            IF (StartButton = TRUE) AND (prevStartButton = FALSE) AND (StopButton = FALSE) AND (isValidScene = TRUE) THEN
                state := RUNNING;
            ELSE
                state := IDLE;
            END_IF;

        RUNNING:
            IF StopButton = TRUE THEN
                state := STOPPED;
            ELSE
                state := RUNNING;
            END_IF;

        STOPPED:
            IF (StopButton = FALSE) AND (StartButton = FALSE) THEN
                state := IDLE;
            ELSE
                state := STOPPED;
            END_IF;
    END_CASE;

    (* --- Step 3: Update Previous Button States --- *)
    prevStartButton := StartButton;
    prevStopButton := StopButton;

    (* --- Step 4: Assign Outputs Based on Current State --- *)
    CASE state OF
        IDLE:
            LightingControl := FALSE;
            SoundControl := FALSE;
            PerformanceInProgress := FALSE;

        RUNNING:
            IF isValidScene = TRUE THEN
                LightingControl := TRUE;
                SoundControl := TRUE;
                PerformanceInProgress := TRUE;
            ELSE
                LightingControl := FALSE;
                SoundControl := FALSE;
                PerformanceInProgress := FALSE;
            END_IF;

        STOPPED:
            LightingControl := FALSE;
            SoundControl := FALSE;
            PerformanceInProgress := FALSE;
    END_CASE;

END_FUNCTION_BLOCK
END_ST