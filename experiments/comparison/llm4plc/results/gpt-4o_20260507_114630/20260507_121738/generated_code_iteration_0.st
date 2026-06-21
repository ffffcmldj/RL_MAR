pascal
START_ST

FUNCTION_BLOCK DoughMixerControl
VAR_INPUT
    IngredientsDetected : BOOL; (* Input for detecting the presence of ingredients *)
END_VAR
VAR_OUTPUT
    MixingInProgress : BOOL; (* Output for controlling the mixing process - on/off *)
END_VAR
VAR
    MixingTimeElapsed : TIME; (* Timer to track the mixing time *)
    MixingTimeLimit : TIME := T#5S; (* Configurable mixing time limit, default is 5 seconds *)
    state : INT := 0; (* Current state of the system: 0 = IDLE, 1 = MIXING, 2 = STOPPED *)
    prevState : INT := -1; (* Previous state of the system, initialized to an invalid state *)
    prevIngredientsDetected : BOOL := FALSE; (* Tracks the previous value of IngredientsDetected for edge detection *)
END_VAR

(* State Machine Logic *)
IF state = 0 THEN (* STATE 0: IDLE *)
    MixingInProgress := FALSE; (* No mixing in progress *)
    
    (* Transition to STATE 1 if IngredientsDetected transitions from FALSE to TRUE *)
    IF NOT prevIngredientsDetected AND IngredientsDetected THEN
        state := 1; (* Transition to MIXING state *)
        MixingInProgress := TRUE; (* Start mixing *)
        MixingTimeElapsed := T#0S; (* Reset the mixing timer *)
    END_IF;

ELSIF state = 1 THEN (* STATE 1: MIXING *)
    MixingInProgress := TRUE; (* Mixing is in progress *)
    
    (* Increment MixingTimeElapsed by T#1S *)
    MixingTimeElapsed := MixingTimeElapsed + T#1S;

    (* Transition to STATE 2 if MixingTimeElapsed >= MixingTimeLimit or IngredientsDetected transitions from TRUE to FALSE *)
    IF MixingTimeElapsed >= MixingTimeLimit OR (prevIngredientsDetected AND NOT IngredientsDetected) THEN
        state := 2; (* Transition to STOPPED state *)
        MixingInProgress := FALSE; (* Stop mixing *)
    END_IF;

ELSIF state = 2 THEN (* STATE 2: STOPPED *)
    MixingInProgress := FALSE; (* No mixing in progress *)

    (* Transition to STATE 0 if IngredientsDetected remains FALSE *)
    IF NOT IngredientsDetected THEN
        state := 0; (* Transition to IDLE state *)
    END_IF;

END_IF;

(* Update the previous state and IngredientsDetected for edge detection *)
prevState := state;
prevIngredientsDetected := IngredientsDetected;

END_FUNCTION_BLOCK

END_ST