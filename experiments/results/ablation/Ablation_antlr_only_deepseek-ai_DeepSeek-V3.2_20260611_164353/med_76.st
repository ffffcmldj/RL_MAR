TYPE
    E_InstallationState : (
        STATE_IDLE,
        STATE_ACTIVE,
        STATE_SAFETY_FAULT
    );
END_TYPE

FUNCTION_BLOCK MultimediaArtInstallationControl
VAR_INPUT
    MotionSensor : BOOL; (* Motion detection input *)
    AudioTrack : BOOL; (* Selected audio track *)
    VisualContent : BOOL; (* Selected visual content *)
    SystemHealthCheck : BOOL := TRUE; (* External system health monitoring *)
    MaxActivationTime : INT := 300; (* Configurable maximum activation time *)
END_VAR

VAR_OUTPUT
    LightingControl : BOOL; (* Lighting control output *)
    AudioControl : BOOL; (* Audio playback control *)
    VisualControl : BOOL; (* Visual display control *)
    ActivationTimer : INT; (* Current activation duration *)
    CurrentState : E_InstallationState; (* For monitoring/debugging *)
    SafetyFault : BOOL; (* Indicates safety violation *)
END_VAR

VAR
    eCurrentState : E_InstallationState := STATE_IDLE;
    eNextState : E_InstallationState := STATE_IDLE;
    bInternalSafetyOK : BOOL := TRUE;
    bPowerMonitorOK : BOOL := TRUE;
END_VAR

(* Main State Machine Execution *)
CASE eCurrentState OF
    STATE_IDLE:
        (* Deactivate all multimedia elements *)
        LightingControl := FALSE;
        AudioControl := FALSE;
        VisualControl := FALSE;
        ActivationTimer := 0;
        SafetyFault := FALSE;
        
        (* Perform safety checks *)
        bInternalSafetyOK := SystemHealthCheck AND bPowerMonitorOK;
        
        (* Transition logic *)
        IF MotionSensor AND bInternalSafetyOK THEN
            eNextState := STATE_ACTIVE;
        ELSIF NOT bInternalSafetyOK THEN
            eNextState := STATE_SAFETY_FAULT;
        ELSE
            eNextState := STATE_IDLE;
        END_IF;
        
    STATE_ACTIVE:
        (* Activate all multimedia elements *)
        LightingControl := TRUE;
        AudioControl := AudioTrack;
        VisualControl := VisualContent;
        
        (* Safety Protocol: Verify all elements are properly enabled before incrementing timer *)
        IF LightingControl AND AudioControl AND VisualControl AND bInternalSafetyOK THEN
            IF ActivationTimer < MaxActivationTime THEN
                ActivationTimer := ActivationTimer + 1;
            END_IF;
        END_IF;
        
        (* Perform continuous safety monitoring *)
        bInternalSafetyOK := SystemHealthCheck AND bPowerMonitorOK;
        
        (* Transition Conditions *)
        IF NOT MotionSensor THEN
            eNextState := STATE_IDLE;
        ELSIF ActivationTimer >= MaxActivationTime THEN
            eNextState := STATE_IDLE;
        ELSIF NOT bInternalSafetyOK THEN
            eNextState := STATE_SAFETY_FAULT;
        ELSE
            eNextState := STATE_ACTIVE;
        END_IF;
        
    STATE_SAFETY_FAULT:
        (* Safety Protocol: Graceful shutdown *)
        LightingControl := FALSE;
        AudioControl := FALSE;
        VisualControl := FALSE;
        SafetyFault := TRUE;
        
        (* Monitor for safety condition resolution *)
        bInternalSafetyOK := SystemHealthCheck AND bPowerMonitorOK;
        
        (* Only exit safety fault when conditions are safe AND no motion detected *)
        IF bInternalSafetyOK AND NOT MotionSensor THEN
            eNextState := STATE_IDLE;
        ELSE
            eNextState := STATE_SAFETY_FAULT;
        END_IF;
        
END_CASE;

(* State Update *)
eCurrentState := eNextState;
CurrentState := eCurrentState;

(* Safety Protocol: Power Monitoring Simulation *)
(* This would typically interface with actual hardware monitoring *)
IF LightingControl AND AudioControl AND VisualControl THEN
    (* Simulate power load check - prevent activation if load is too high *)
    bPowerMonitorOK := TRUE; (* Replace with actual power monitoring logic *)
ELSE
    bPowerMonitorOK := TRUE;
END_IF;

END_FUNCTION_BLOCK