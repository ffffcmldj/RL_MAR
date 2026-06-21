(*
    ShredderControl FUNCTION_BLOCK
    Final, production-ready implementation.
    Synthesized from specialist agent inputs with critical evaluation.
    Compliant with IEC 61131-3 standard.
*)

FUNCTION_BLOCK ShredderControl
VAR_INPUT
    StartButton : BOOL;        (* Momentary start command *)
    StopButton : BOOL;         (* Momentary stop command *)
    EmergencyStop : BOOL;      (* NC contact, TRUE = pressed/fault *)
    MaterialInFeed : BOOL;     (* Presence detected in feed chute *)
    JammedSensor : BOOL;       (* TRUE when a jam is detected *)
END_VAR
VAR_OUTPUT
    MotorControl : BOOL;       (* Command to motor starter *)
    SafetyRelay : BOOL;        (* Command to safety relay coil *)
END_VAR
VAR
    fbMotorLatch : SR;         (* Standard Set-Reset Latch for motor state *)
    bEmergencyCondition : BOOL;(* Consolidated emergency signal *)
    bRunPermissive : BOOL;     (* Permissive for normal run requests *)
END_VAR

(* --- Priority 1: Determine Emergency Condition --- *)
bEmergencyCondition := EmergencyStop OR JammedSensor;

(* --- Priority 2: Safety Relay Logic (Directly controlled by safety state) --- *)
SafetyRelay := NOT bEmergencyCondition;

(* --- Priority 3: Normal Run Permissive Logic --- *)
bRunPermissive := NOT bEmergencyCondition AND NOT StopButton;

(* --- Priority 4: Motor Latch Logic --- *)
(* Set Condition: Permissive is TRUE AND (Start button pressed OR material in feed) *)
fbMotorLatch(S1 := bRunPermissive AND (StartButton OR MaterialInFeed),
             R  := NOT bRunPermissive); (* Reset if permissive is lost *)

(* --- Final Motor Output Assignment --- *)
(* Motor runs only if the latch is set AND the safety relay is active (fail-safe check) *)
MotorControl := fbMotorLatch.Q1 AND SafetyRelay;

END_FUNCTION_BLOCK