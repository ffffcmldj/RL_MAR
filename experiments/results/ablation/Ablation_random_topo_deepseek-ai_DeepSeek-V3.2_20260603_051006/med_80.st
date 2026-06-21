FUNCTION_BLOCK DoughMixerControl
VAR_INPUT
    IngredientsDetected : BOOL; (* Input for detecting the presence of ingredients *)
END_VAR

VAR_OUTPUT
    MixingInProgress : BOOL; (* Output for controlling the mixing process - on/off *)
END_VAR

VAR
    MixingTimeElapsed : TIME; (* Timer to track the mixing time *)
    MixingTimeLimit : TIME := T#5S; (* Mixing time limit - 5 seconds *)
    IngredientsDetectedPrev : BOOL; (* Previous state for edge detection *)
    StartTime : TIME; (* Stores the system time when mixing starts *)
    SystemTime : TIME; (* Current system time *)
END_VAR

(* Main logic *)
SystemTime := TIME(); (* Get current system time *)

(* Rising edge detection for IngredientsDetected *)
IF IngredientsDetected AND NOT IngredientsDetectedPrev THEN
    (* Start mixing cycle *)
    MixingInProgress := TRUE;
    StartTime := SystemTime; (* Record start time *)
    MixingTimeElapsed := T#0S; (* Reset elapsed time *)
END_IF;

(* Update previous state for next cycle *)
IngredientsDetectedPrev := IngredientsDetected;

(* Stop conditions *)
IF NOT IngredientsDetected THEN
    (* Stop if ingredients are no longer detected *)
    MixingInProgress := FALSE;
ELSIF MixingInProgress THEN
    (* Calculate elapsed time while mixing *)
    MixingTimeElapsed := SystemTime - StartTime;
    
    (* Stop if time limit is reached *)
    IF MixingTimeElapsed >= MixingTimeLimit THEN
        MixingInProgress := FALSE;
    END_IF;
END_IF;

(* Ensure timer doesn't increment when not mixing *)
IF NOT MixingInProgress THEN
    MixingTimeElapsed := MixingTimeElapsed; (* Hold current value *)
END_IF;
END_FUNCTION_BLOCK