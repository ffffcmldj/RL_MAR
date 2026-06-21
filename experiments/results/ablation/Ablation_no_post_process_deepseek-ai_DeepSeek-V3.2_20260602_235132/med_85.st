(* ============================================================================
   FINAL, PRODUCTION-READY FUNCTION_BLOCK FOR INDUSTRIAL SHREDDER CONTROL
   Senior PLC Commissioning Engineer Synthesis
   IEC 61131-3 Structured Text
   Priority: Safety > Normal Stop > Normal Start
   Features: Highest-priority emergency stop/jam, latching run command,
             fail-safe safety relay, manual reset after emergency.
============================================================================ *)

FUNCTION_BLOCK ShredderControl
VAR_INPUT
    (* Primary Command Inputs *)
    StartButton : BOOL;        (* Rising edge triggers start. Physical button. *)
    StopButton : BOOL;         (* Command to stop under normal conditions. *)
    EmergencyStop : BOOL;      (* TRUE = Emergency Stop Activated (Highest Priority). *)
    MaterialInFeed : BOOL;     (* TRUE = Material detected, requests auto-start. *)
    JammedSensor : BOOL;       (* TRUE = Jam detected (Highest Priority). *)
    (* System Feedback *)
    MotorStatus : BOOL;        (* Feedback contactor/motor running status. *)
    (* Safety & Reset *)
    ResetButton : BOOL;        (* Manual reset required after an emergency condition. *)
END_VAR

VAR_OUTPUT
    MotorControl : BOOL;       (* Command to motor contactor/ drive. *)
    SafetyRelay : BOOL;        (* Control for safety relay. TRUE = Safe, Energized. *)
    EmergencyLatched : BOOL;   (* TRUE indicates an emergency stop or jam is latched. *)
END_VAR

VAR
    (* State Variables *)
    MotorRunRequest : BOOL;    (* Internal latch for the run command. *)
    EmergencyCondition : BOOL; (* Combined emergency stop/jam signal. *)
    EmergencyLatch : BOOL;     (* Latch to remember an emergency occurred. *)
    StartPulse : BOOL;         (* Edge detection for StartButton. *)
    StartPulse_Memory : BOOL;  (* Memory for edge detection. *)
    ResetPulse : BOOL;         (* Edge detection for ResetButton. *)
    ResetPulse_Memory : BOOL;  (* Memory for edge detection. *)
END_VAR

(* ----------------------------------------------------------------------------
   INITIALIZATION & EDGE DETECTION
---------------------------------------------------------------------------- *)
(* Edge detection for push-button inputs (Start, Reset) *)
StartPulse := StartButton AND NOT StartPulse_Memory;
StartPulse_Memory := StartButton;

ResetPulse := ResetButton AND NOT ResetPulse_Memory;
ResetPulse_Memory := ResetButton;

(* ----------------------------------------------------------------------------
   SAFETY LOGIC: HIGHEST PRIORITY
---------------------------------------------------------------------------- *)
(* 1. Define the active emergency condition. *)
EmergencyCondition := EmergencyStop OR JammedSensor;

(* 2. Latch the emergency condition. Once TRUE, it stays TRUE until manually reset. *)
IF EmergencyCondition THEN
    EmergencyLatch := TRUE;
ELSIF ResetPulse THEN
    EmergencyLatch := FALSE;
END_IF;

(* ----------------------------------------------------------------------------
   MOTOR CONTROL LOGIC
---------------------------------------------------------------------------- *)
(* Priority 1: Emergency Latch (Highest Priority - Unconditional Stop) *)
IF EmergencyLatch THEN
    MotorRunRequest := FALSE;
(* Priority 2: Normal Stop Command *)
ELSIF StopButton THEN
    MotorRunRequest := FALSE;
(* Priority 3: Start Command (from button pulse OR material presence) *)
ELSIF StartPulse OR MaterialInFeed THEN
    MotorRunRequest := TRUE;
(* ELSE: Maintain current state (MotorRunRequest retains its value) *)
END_IF;

(* Final motor command is only valid if no active emergency condition exists. *)
MotorControl := MotorRunRequest AND NOT EmergencyCondition;

(* ----------------------------------------------------------------------------
   SAFETY RELAY LOGIC (FAIL-SAFE)
---------------------------------------------------------------------------- *)
(* Safety Relay is ONLY energized when:
   - No active emergency condition (EmergencyStop OR JammedSensor).
   - The emergency latch has been cleared (i.e., system has been reset).
   This ensures the relay drops out on any active fault and requires a reset. *)
SafetyRelay := NOT EmergencyCondition AND NOT EmergencyLatch;

(* ----------------------------------------------------------------------------
   STATUS OUTPUT
---------------------------------------------------------------------------- *)
EmergencyLatched := EmergencyLatch;

END_FUNCTION_BLOCK