START_ST
FUNCTION_BLOCK ShredderControl
VAR_INPUT
    StartButton : BOOL;         (* Input for the start button *)
    StopButton : BOOL;          (* Input for the stop button *)
    EmergencyStop : BOOL;       (* Input for the emergency stop button *)
    MotorStatus : BOOL;         (* Feedback status of the shredder motor *)
    MaterialInFeed : BOOL;      (* Input for material being fed into the shredder *)
    JammedSensor : BOOL;        (* Input for detecting material jamming *)
END_VAR
VAR_OUTPUT
    MotorControl : BOOL;        (* Output for controlling the shredder motor *)
    SafetyRelay : BOOL;         (* Output for safety relay: TRUE=Safe, FALSE=Unsafe *)
END_VAR
VAR
    state : INT;                (* Current state of the FSM: 0=IDLE, 1=RUNNING, 2=EMERGENCY_STOP *)
    prevState : INT;            (* Previous state, stored for potential future use (e.g., logging) *)
END_VAR

(* State Machine Execution *)
(* Highest priority: Check for Emergency Stop or Jam conditions *)
IF EmergencyStop OR JammedSensor THEN
    state := 2; (* EMERGENCY_STOP *)
ELSE
    (* Normal state transitions based on current state *)
    CASE state OF
        0: (* IDLE *)
            (* Transition to RUNNING if StartButton pressed OR MaterialInFeed detected *)
            IF StartButton OR MaterialInFeed THEN
                state := 1; (* RUNNING *)
            END_IF;
            
        1: (* RUNNING *)
            (* Transition to IDLE if StopButton pressed *)
            IF StopButton THEN
                state := 0; (* IDLE *)
            END_IF;
            
        2: (* EMERGENCY_STOP *)
            (* Transition back to IDLE only when emergency conditions are cleared *)
            (* The IF condition above already ensures EmergencyStop=FALSE AND JammedSensor=FALSE *)
            state := 0; (* IDLE *)
            
    END_CASE;
END_IF;

(* Set outputs based on current state *)
CASE state OF
    0: (* IDLE *)
        MotorControl := FALSE;
        SafetyRelay := TRUE;
        
    1: (* RUNNING *)
        MotorControl := TRUE;
        SafetyRelay := TRUE;
        
    2: (* EMERGENCY_STOP *)
        MotorControl := FALSE;
        SafetyRelay := FALSE;
        
END_CASE;

(* Store current state for next cycle *)
prevState := state;

END_FUNCTION_BLOCK
END_ST