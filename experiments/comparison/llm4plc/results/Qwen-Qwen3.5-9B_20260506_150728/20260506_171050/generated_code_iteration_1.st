START_REASON
The previous code failed CODESYS compiler validation (Error 500) primarily due to the use of the `CASE` statement with integer literals (`0`, `1`, `2`) as selectors in a `FUNCTION_BLOCK`. While standard IEC 61131-3 allows this, many strict CODESYS compilers (especially older versions or specific configurations) require the `CASE` selector to be of a specific enumerated type or require the `END_CASE` keyword instead of `ENDCASE` if the syntax is slightly off.

However, the most robust fix for CODESYS ST is to:
1.  Define an `ENUM` type for the states to ensure type safety and readability.
2.  Replace the integer literals in the `CASE` statements with the enum values.
3.  Ensure all keywords are spelled correctly (`END_CASE` is the standard, though `ENDCASE` is often accepted, `END_CASE` is safer).
4.  Remove comments that start with `(*` inside the `BEGIN` block if they are causing parsing issues in very strict modes, though usually comments are fine. The main culprit is often the mix of integer literals in CASE without a declared enum type in strict environments.

I will refactor the code to use a dedicated `ENUM` for states and ensure strict compliance with CODESYS syntax.
END_REASON

START_ST
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

TYPE T_TheaterState :
    IDLE := 0,
    RUNNING := 1,
    STOPPED := 2
END_TYPE;

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