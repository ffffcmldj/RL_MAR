(*
    Multimedia Art Installation Control
    FUNCTION_BLOCK: MultimediaArtInstallationControl
    Description: Controls synchronization of audio, visual, and lighting elements
                 based on motion detection with safety protocols.
    State Machine: 0=IDLE, 1=ACTIVE, 2=SAFETY
*)

FUNCTION_BLOCK MultimediaArtInstallationControl
VAR_INPUT
    MotionSensor : BOOL;           (* Motion detection input *)
    AudioTrack : BOOL;             (* Selected audio track enable *)
    VisualContent : BOOL;          (* Selected visual content enable *)
    SystemCheck : BOOL;            (* Safety system check input *)
    PowerStatus : BOOL;            (* Power usage monitoring input *)
END_VAR

VAR_OUTPUT
    LightingControl : BOOL;        (* Lighting control output *)
    AudioControl : BOOL;           (* Audio playback control output *)
    VisualControl : BOOL;          (* Visual display control output *)
    TimerValue : INT;              (* Current activation timer value *)
    SystemStatus : BOOL;           (* Overall system status *)
END_VAR

VAR
    ActivationTimer : INT;         (* Timer for activation duration in seconds *)
    CurrentState : INT;            (* Current state identifier *)
    NextState : INT;               (* Next state identifier *)
    CycleCounter : INT;            (* Cycle counter for timing *)
    SafetyOverride : BOOL;         (* Safety override flag *)
    FirstCycle : BOOL := TRUE;     (* First cycle flag for initialization *)
END_VAR

VAR CONSTANT
    MAX_ACTIVATION_TIME : INT := 300;     (* 300 seconds maximum activation *)
    CYCLE_TIME_MS : INT := 100;           (* 100ms cycle time *)
    CYCLES_PER_SECOND : INT := 10;        (* 10 cycles per second for 100ms cycle *)
    STATE_IDLE : INT := 0;                (* Idle state identifier *)
    STATE_ACTIVE : INT := 1;              (* Active state identifier *)
    STATE_SAFETY : INT := 2;              (* Safety state identifier *)
END_VAR

(* Initialization on first cycle *)
IF FirstCycle THEN
    CurrentState := STATE_IDLE;
    NextState := STATE_IDLE;
    ActivationTimer := 0;
    CycleCounter := 0;
    SafetyOverride := FALSE;
    SystemStatus := TRUE;
    FirstCycle := FALSE;
END_IF;

(* Main state machine *)
CASE CurrentState OF
    STATE_IDLE:
        (* Actions executed in idle state *)
        LightingControl := FALSE;
        AudioControl := FALSE;
        VisualControl := FALSE;
        ActivationTimer := 0;
        CycleCounter := 0;
        TimerValue := 0;
        
        (* Transition logic from idle state *)
        IF NOT SystemCheck OR NOT PowerStatus THEN
            NextState := STATE_SAFETY;
        ELSIF MotionSensor AND SystemCheck AND PowerStatus THEN
            NextState := STATE_ACTIVE;
        ELSE
            NextState := STATE_IDLE;
        END_IF;
        
    STATE_ACTIVE:
        (* Actions executed in active state *)
        LightingControl := TRUE;
        AudioControl := AudioTrack AND SystemCheck;     (* Only activate if system check passes *)
        VisualControl := VisualContent AND SystemCheck; (* Only activate if system check passes *)
        
        (* Increment cycle counter for timing *)
        CycleCounter := CycleCounter + 1;
        
        (* Update timer every second (10 cycles at 100ms each) *)
        IF CycleCounter >= CYCLES_PER_SECOND THEN
            ActivationTimer := ActivationTimer + 1;
            CycleCounter := 0;
        END_IF;
        
        TimerValue := ActivationTimer;
        
        (* Transition logic from active state *)
        (* Safety override takes highest priority *)
        IF NOT SystemCheck OR NOT PowerStatus THEN
            NextState := STATE_SAFETY;
        (* Deactivate if no motion detected *)
        ELSIF NOT MotionSensor THEN
            NextState := STATE_IDLE;
        (* Deactivate if timer reaches maximum *)
        ELSIF ActivationTimer >= MAX_ACTIVATION_TIME THEN
            NextState := STATE_IDLE;
        (* Stay in active state *)
        ELSE
            NextState := STATE_ACTIVE;
        END_IF;
        
    STATE_SAFETY:
        (* Actions executed in safety state *)
        LightingControl := FALSE;
        AudioControl := FALSE;
        VisualControl := FALSE;
        ActivationTimer := 0;
        CycleCounter := 0;
        SystemStatus := FALSE;
        SafetyOverride := TRUE;
        
        (* Transition logic from safety state *)
        IF SystemCheck AND PowerStatus THEN
            SafetyOverride := FALSE;
            SystemStatus := TRUE;
            NextState := STATE_IDLE;
        ELSE
            NextState := STATE_SAFETY;
        END_IF;
        
END_CASE;

(* State transition *)
CurrentState := NextState;

(* Additional safety protocol: Power management consideration *)
IF LightingControl AND AudioControl AND VisualControl THEN
    (* Optional: Implement staggered activation or power limiting *)
    (* based on specific installation power requirements *)
END_IF;

END_FUNCTION_BLOCK