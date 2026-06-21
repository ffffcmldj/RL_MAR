START_ST
FUNCTION_BLOCK TheaterControl
VAR_INPUT
    StartButton : BOOL; (* Input for starting a performance *)
    StopButton : BOOL; (* Input for stopping a performance *)
    SceneNumber : INT; (* Input for selecting the scene or act *)
END_VAR
VAR_OUTPUT
    LightingControl : BOOL; (* Output for controlling lighting *)
    SoundControl : BOOL; (* Output for controlling sound *)
    PerformanceInProgress : BOOL; (* Indicator for an ongoing performance *)
END_VAR
VAR
    state : INT; (* The current FSM state: 0=IDLE, 1=RUNNING, 2=STOPPED *)
    prevStartButton : BOOL; (* Previous state of StartButton for edge detection *)
    prevStopButton : BOOL; (* Previous state of StopButton for edge detection *)
    isValidScene : BOOL; (* Temporary variable to check if SceneNumber is valid *)
END_VAR

BEGIN
    (* --- Step 1: Validate Scene Number --- *)
    (* Check if SceneNumber is 1, 2, or 3 *)
    IF (SceneNumber >= 1) AND (SceneNumber <= 3) THEN
        isValidScene := TRUE;
    ELSE
        isValidScene := FALSE;
    END_IF;

    (* --- Step 2: State Machine Logic --- *)

    (* Transition Logic: Determine Next State *)
    (* 
       State 0 (IDLE) -> State 1 (RUNNING):
       Condition: StartButton is TRUE (Rising Edge) AND StopButton is FALSE AND isValidScene is TRUE.
       Note: We use rising edge detection (StartButton AND NOT prevStartButton) to ensure
       the performance starts only once per press, preventing toggling if the button is held.
    *)
    (* 
       State 1 (RUNNING) -> State 2 (STOPPED):
       Condition: StopButton is TRUE.
    *)
    (* 
       State 2 (STOPPED) -> State 0 (IDLE):
       Condition: StopButton is FALSE AND StartButton is FALSE.
       (If StartButton is still TRUE in State 2, it will transition to State 1 in the next cycle,
        effectively allowing immediate restart if the button remains held, which satisfies the
        "override" requirement while allowing intentional restart).
    *)

    (* Calculate Next State based on current inputs and previous state *)
    CASE state OF
        0: (* IDLE *)
            (* Transition to RUNNING if StartButton rises, Stop is false, and scene is valid *)
            IF (StartButton = TRUE) AND (prevStartButton = FALSE) AND (StopButton = FALSE) AND (isValidScene = TRUE) THEN
                state := 1; (* Transition to RUNNING *)
            ELSE
                state := 0; (* Remain in IDLE *)
            END_IF;

        1: (* RUNNING *)
            (* Transition to STOPPED if StopButton is pressed *)
            IF StopButton = TRUE THEN
                state := 2; (* Transition to STOPPED *)
            ELSE
                state := 1; (* Remain in RUNNING *)
            END_IF;

        2: (* STOPPED *)
            (* Transition to IDLE if StopButton is released and StartButton is not held *)
            (* If StartButton is held while Stop is released, it transitions to RUNNING immediately *)
            IF (StopButton = FALSE) AND (StartButton = FALSE) THEN
                state := 0; (* Transition to IDLE *)
            ELSE
                state := 2; (* Remain in STOPPED until conditions change *)
            END_IF;
    ENDCASE;

    (* --- Step 3: Update Previous Button States --- *)
    (* Store current button states for the next cycle's edge detection *)
    prevStartButton := StartButton;
    prevStopButton := StopButton;

    (* --- Step 4: Assign Outputs Based on Current State --- *)
    CASE state OF
        0: (* IDLE *)
            LightingControl := FALSE;
            SoundControl := FALSE;
            PerformanceInProgress := FALSE;

        1: (* RUNNING *)
            (* Outputs are driven by the validity of the scene number *)
            IF isValidScene = TRUE THEN
                LightingControl := TRUE;
                SoundControl := TRUE;
                PerformanceInProgress := TRUE;
            ELSE
                (* If an invalid scene was selected while trying to start, 
                   the state machine logic above prevents entering state 1,
                   but as a safety fallback or if logic changes, ensure outputs are off *)
                LightingControl := FALSE;
                SoundControl := FALSE;
                PerformanceInProgress := FALSE;
            END_IF;

        2: (* STOPPED *)
            LightingControl := FALSE;
            SoundControl := FALSE;
            PerformanceInProgress := FALSE;
    ENDCASE;

END_FUNCTION_BLOCK
END_ST