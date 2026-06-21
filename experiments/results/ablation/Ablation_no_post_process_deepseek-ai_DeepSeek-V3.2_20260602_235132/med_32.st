(* Greenhouse Watering System FUNCTION_BLOCK *)
(* Implements hysteresis control with 30% activation and 70% deactivation thresholds *)
(* Includes configurable response delay for state transitions *)

FUNCTION_BLOCK GreenhouseWateringSystem
VAR_INPUT
    SoilMoistureSensor : REAL; (* Input: Current soil moisture reading (0-100%) *)
    EnableSystem : BOOL := TRUE; (* Input: Master enable for the system *)
    ResponseDelay : TIME := T#5s; (* Input: Configurable delay for state transitions *)
END_VAR

VAR_OUTPUT
    SprinklersOn : BOOL := FALSE; (* Output: Control signal for sprinkler activation *)
    SystemState : INT := 0; (* Output: Current state of the system (0=Idle, 1=Activating, 2=Active, 3=Deactivating) *)
    LastMoistureReading : REAL := 0.0; (* Output: Last valid moisture reading *)
END_VAR

VAR
    (* Internal state variables *)
    CurrentState : INT := 0; (* 0=IDLE, 1=ACTIVATING, 2=ACTIVE, 3=DEACTIVATING *)
    
    (* Timer for response delay *)
    TransitionTimer : TON;
    
    (* Configuration constants *)
    LOW_THRESHOLD : REAL := 30.0; (* Activation threshold *)
    HIGH_THRESHOLD : REAL := 70.0; (* Deactivation threshold *)
    
    (* Internal flags *)
    TimerActive : BOOL := FALSE;
END_VAR

(* Main state machine logic *)
IF NOT EnableSystem THEN
    (* System disabled - reset to safe state *)
    SprinklersOn := FALSE;
    CurrentState := 0;
    TransitionTimer(IN:=FALSE, PT:=ResponseDelay);
    SystemState := CurrentState;
    RETURN;
END_IF;

(* Update last moisture reading for monitoring *)
LastMoistureReading := SoilMoistureSensor;

(* State machine implementation *)
CASE CurrentState OF
    0: (* IDLE STATE - Sprinklers are OFF *)
        SprinklersOn := FALSE;
        TransitionTimer(IN:=FALSE, PT:=ResponseDelay);
        TimerActive := FALSE;
        
        (* Check if moisture has dropped below activation threshold *)
        IF SoilMoistureSensor < LOW_THRESHOLD THEN
            CurrentState := 1; (* Transition to ACTIVATING state *)
            TransitionTimer(IN:=TRUE, PT:=ResponseDelay);
            TimerActive := TRUE;
        END_IF;
        
    1: (* ACTIVATING STATE - Waiting for delay before turning sprinklers ON *)
        SprinklersOn := FALSE;
        
        (* Continue timing if timer is active *)
        IF TimerActive THEN
            TransitionTimer(IN:=TRUE, PT:=ResponseDelay);
            
            (* Check if timer has completed *)
            IF TransitionTimer.Q THEN
                CurrentState := 2; (* Transition to ACTIVE state *)
                SprinklersOn := TRUE;
                TransitionTimer(IN:=FALSE, PT:=ResponseDelay);
                TimerActive := FALSE;
            END_IF;
        ELSE
            (* Timer was not properly started - restart it *)
            TransitionTimer(IN:=TRUE, PT:=ResponseDelay);
            TimerActive := TRUE;
        END_IF;
        
        (* Safety check: If moisture rises above activation threshold during delay, cancel activation *)
        IF SoilMoistureSensor >= LOW_THRESHOLD THEN
            CurrentState := 0; (* Return to IDLE state *)
            TransitionTimer(IN:=FALSE, PT:=ResponseDelay);
            TimerActive := FALSE;
            SprinklersOn := FALSE;
        END_IF;
        
    2: (* ACTIVE STATE - Sprinklers are ON *)
        SprinklersOn := TRUE;
        TransitionTimer(IN:=FALSE, PT:=ResponseDelay);
        TimerActive := FALSE;
        
        (* Check if moisture has risen above deactivation threshold *)
        IF SoilMoistureSensor > HIGH_THRESHOLD THEN
            CurrentState := 3; (* Transition to DEACTIVATING state *)
            TransitionTimer(IN:=TRUE, PT:=ResponseDelay);
            TimerActive := TRUE;
        END_IF;
        
    3: (* DEACTIVATING STATE - Waiting for delay before turning sprinklers OFF *)
        SprinklersOn := TRUE;
        
        (* Continue timing if timer is active *)
        IF TimerActive THEN
            TransitionTimer(IN:=TRUE, PT:=ResponseDelay);
            
            (* Check if timer has completed *)
            IF TransitionTimer.Q THEN
                CurrentState := 0; (* Transition to IDLE state *)
                SprinklersOn := FALSE;
                TransitionTimer(IN:=FALSE, PT:=ResponseDelay);
                TimerActive := FALSE;
            END_IF;
        ELSE
            (* Timer was not properly started - restart it *)
            TransitionTimer(IN:=TRUE, PT:=ResponseDelay);
            TimerActive := TRUE;
        END_IF;
        
        (* Safety check: If moisture drops below deactivation threshold during delay, cancel deactivation *)
        IF SoilMoistureSensor <= HIGH_THRESHOLD THEN
            CurrentState := 2; (* Return to ACTIVE state *)
            TransitionTimer(IN:=FALSE, PT:=ResponseDelay);
            TimerActive := FALSE;
            SprinklersOn := TRUE;
        END_IF;
        
    ELSE
        (* Error state - reset to safe IDLE state *)
        CurrentState := 0;
        SprinklersOn := FALSE;
        TransitionTimer(IN:=FALSE, PT:=ResponseDelay);
        TimerActive := FALSE;
        
END_CASE;

(* Update output state for monitoring *)
SystemState := CurrentState;

(* Assertion checks for system safety *)
(* Emergency shutoff if moisture exceeds maximum safe limit *)
IF SoilMoistureSensor > 95.0 THEN
    SprinklersOn := FALSE;
    CurrentState := 0;
    TransitionTimer(IN:=FALSE, PT:=ResponseDelay);
    TimerActive := FALSE;
END_IF;

(* Emergency activation if moisture drops below critical minimum *)
IF SoilMoistureSensor < 5.0 THEN
    SprinklersOn := TRUE;
    CurrentState := 2;
    TransitionTimer(IN:=FALSE, PT:=ResponseDelay);
    TimerActive := FALSE;
END_IF;

END_FUNCTION_BLOCK;