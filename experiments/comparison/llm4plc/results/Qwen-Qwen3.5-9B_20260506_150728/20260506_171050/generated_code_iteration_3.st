START_REASON
The previous code failed due to a character encoding issue. The error message `'gbk' codec can't decode byte 0xaa` indicates that the code contains non-ASCII characters (likely Chinese comments or keywords from a previous attempt or copy-paste error) that are not compatible with the expected ASCII/UTF-8 encoding for the IEC 61131-3 compiler. Specifically, the phrase "未知的类型" (Unknown type) in the previous error log suggests Chinese characters were present in the logic or comments, causing the parser to fail immediately.

To fix this:
1.  Remove all non-ASCII characters (Chinese text) from the code.
2.  Replace them with standard English comments.
3.  Ensure the `TYPE` definition is in the global scope (which was correctly done in the previous iteration, so we keep that structure).
4.  Verify strict adherence to IEC 61131-3 syntax.
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