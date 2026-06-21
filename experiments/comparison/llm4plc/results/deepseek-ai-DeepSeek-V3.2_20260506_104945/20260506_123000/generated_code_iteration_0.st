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
    state : INT;
    prevState : INT;
    startRisingEdge : BOOL;
    stopRisingEdge : BOOL;
END_VAR

    (* Edge detection for buttons *)
    startRisingEdge := StartButton AND NOT startRisingEdge;
    stopRisingEdge := StopButton AND NOT stopRisingEdge;

    (* Store previous state for edge detection reset logic *)
    prevState := state;

    (* State machine logic *)
    CASE state OF
        0: (* IDLE *)
            LightingControl := FALSE;
            SoundControl := FALSE;
            PerformanceInProgress := FALSE;
            
            IF stopRisingEdge THEN
                state := 4; (* Transition to STOPPED *)
            ELSIF startRisingEdge THEN
                CASE SceneNumber OF
                    1: state := 1;
                    2: state := 2;
                    3: state := 3;
                    ELSE
                        state := 0; (* Invalid scene, remain idle *)
                END_CASE;
            END_IF;
            
        1: (* PERFORMANCE_SCENE_1 *)
            LightingControl := TRUE;
            SoundControl := TRUE;
            PerformanceInProgress := TRUE;
            
            IF stopRisingEdge THEN
                state := 4; (* Transition to STOPPED *)
            END_IF;
            
        2: (* PERFORMANCE_SCENE_2 *)
            LightingControl := TRUE;
            SoundControl := TRUE;
            PerformanceInProgress := TRUE;
            
            IF stopRisingEdge THEN
                state := 4; (* Transition to STOPPED *)
            END_IF;
            
        3: (* PERFORMANCE_SCENE_3 *)
            LightingControl := TRUE;
            SoundControl := TRUE;
            PerformanceInProgress := TRUE;
            
            IF stopRisingEdge THEN
                state := 4; (* Transition to STOPPED *)
            END_IF;
            
        4: (* STOPPED *)
            LightingControl := FALSE;
            SoundControl := FALSE;
            PerformanceInProgress := FALSE;
            
            (* Automatic transition back to IDLE *)
            state := 0;
            
    END_CASE;

    (* Reset edge detection flags when state changes *)
    IF state <> prevState THEN
        startRisingEdge := FALSE;
        stopRisingEdge := FALSE;
    END_IF;

END_FUNCTION_BLOCK
END_ST