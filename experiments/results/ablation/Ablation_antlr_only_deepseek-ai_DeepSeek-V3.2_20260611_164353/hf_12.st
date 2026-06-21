(*
    FUNCTION_BLOCK: MaterialMixing
    Description: Controls a material proportioning process with manual and automatic operation modes.
    Features:
    - Emergency stop (estop) immediately deactivates all outputs.
    - Manual mode: Toggle control for each valve and the mixing motor via pushbuttons.
    - Automatic mode: Executes a sequenced process based on level sensor and process mode.
    - Includes safety interlocks and diagnostic checks as per hazard analysis.
*)

TYPE
    E_AutoStep : (
        Step_Idle := 0,
        Step_ValveA := 1,
        Step_ValveB := 2,
        Step_ProcessBranch := 3,
        Step_MixMotor := 4,
        Step_ValveD := 5
    );
END_TYPE

FUNCTION_BLOCK MaterialMixing
VAR_INPUT
    estop : BOOL; (* Emergency Stop, TRUE = Normal, FALSE = Stop *)
    opeMode : BOOL; (* Operation Mode, FALSE = Manual, TRUE = Automatic *)
    valveAStart : BOOL; (* Valve A Toggle Command *)
    valveBStart : BOOL; (* Valve B Toggle Command *)
    valveCStart : BOOL; (* Valve C Toggle Command *)
    valveDStart : BOOL; (* Valve D Toggle Command *)
    mixMotorStart : BOOL; (* Mixing Motor Toggle Command *)
    autoStart : BOOL; (* Automatic Sequence Start/Stop Toggle *)
    processMode : BOOL; (* Process Mode, FALSE = Simple Mix, TRUE = Add Material C *)
    levelSensor : INT; (* Liquid Level [cm] *)
    mixMotorComplete : BOOL; (* Mixing Motor Completed Cycle *)
END_VAR
VAR_OUTPUT
    valveARun : BOOL; (* Valve A Command *)
    valveBRun : BOOL; (* Valve B Command *)
    valveCRun : BOOL; (* Valve C Command *)
    valveDRun : BOOL; (* Valve D Command *)
    mixMotorRun : BOOL; (* Mixing Motor Command *)
END_VAR
VAR
    (* Edge detection for manual and auto start buttons *)
    rTrig_ValveAStart : R_TRIG;
    rTrig_ValveBStart : R_TRIG;
    rTrig_ValveCStart : R_TRIG;
    rTrig_ValveDStart : R_TRIG;
    rTrig_MixMotorStart : R_TRIG;
    rTrig_AutoStart : R_TRIG;

    (* Automatic sequence control *)
    xAutoActive : BOOL := FALSE;
    eAutoStep : E_AutoStep := E_AutoStep.Step_Idle;

    (* Safety and diagnostic flags *)
    xLevelSensorFault : BOOL := FALSE;
    xMixMotorTimeoutFault : BOOL := FALSE;
    tMixMotorTimer : TON;
    tMixMotorTimeoutTime : TIME := T#30s; (* Example watchdog time *)

    (* Internal state for manual toggle logic *)
    xManualValveA : BOOL := FALSE;
    xManualValveB : BOOL := FALSE;
    xManualValveC : BOOL := FALSE;
    xManualValveD : BOOL := FALSE;
    xManualMixMotor : BOOL := FALSE;
END_VAR

(*----------------------------------------------------------------------------*)
(* 1. PRIMARY SAFETY: EMERGENCY STOP OVERRIDE                                 *)
(*    All final output commands are gated by the estop signal.                *)
(*----------------------------------------------------------------------------*)
IF NOT estop THEN
    valveARun := FALSE;
    valveBRun := FALSE;
    valveCRun := FALSE;
    valveDRun := FALSE;
    mixMotorRun := FALSE;
    xAutoActive := FALSE;
    eAutoStep := E_AutoStep.Step_Idle;
    RETURN; (* Exit function block immediately on estop *)
END_IF;

(*----------------------------------------------------------------------------*)
(* 2. SENSOR DIAGNOSTICS & PLAUSIBILITY CHECKS                                *)
(*    Implements mitigation for "Sensor Failure or Signal Loss" hazard.       *)
(*----------------------------------------------------------------------------*)
xLevelSensorFault := (levelSensor < 0) OR (levelSensor > 110); (* Example range check *)

(*----------------------------------------------------------------------------*)
(* 3. MODE SELECTION: MANUAL OR AUTOMATIC                                     *)
(*----------------------------------------------------------------------------*)
IF NOT opeMode THEN (* MANUAL MODE *)
    (* Deactivate automatic sequence *)
    xAutoActive := FALSE;
    eAutoStep := E_AutoStep.Step_Idle;

    (* Edge detection for manual toggle buttons *)
    rTrig_ValveAStart(CLK := valveAStart);
    rTrig_ValveBStart(CLK := valveBStart);
    rTrig_ValveCStart(CLK := valveCStart);
    rTrig_ValveDStart(CLK := valveDStart);
    rTrig_MixMotorStart(CLK := mixMotorStart);

    (* Toggle logic for manual control *)
    IF rTrig_ValveAStart.Q THEN
        xManualValveA := NOT xManualValveA;
    END_IF;
    IF rTrig_ValveBStart.Q THEN
        xManualValveB := NOT xManualValveB;
    END_IF;
    IF rTrig_ValveCStart.Q THEN
        xManualValveC := NOT xManualValveC;
    END_IF;
    IF rTrig_ValveDStart.Q THEN
        xManualValveD := NOT xManualValveD;
    END_IF;
    IF rTrig_MixMotorStart.Q THEN
        xManualMixMotor := NOT xManualMixMotor;
    END_IF;

    (* Apply manual commands to outputs *)
    valveARun := xManualValveA;
    valveBRun := xManualValveB;
    valveCRun := xManualValveC;
    valveDRun := xManualValveD;
    mixMotorRun := xManualMixMotor;

ELSE (* AUTOMATIC MODE *)
    (*--------------------------------------------------------------------*)
    (* 4. AUTOMATIC SEQUENCE CONTROL                                      *)
    (*    Implements the specified process flow with state machine.       *)
    (*--------------------------------------------------------------------*)
    (* Edge detection for auto start/stop toggle *)
    rTrig_AutoStart(CLK := autoStart);
    IF rTrig_AutoStart.Q THEN
        xAutoActive := NOT xAutoActive;
        IF xAutoActive THEN
            (* Start sequence: Ensure safe initial state *)
            valveDRun := FALSE; (* Interlock: Close outlet before starting *)
            eAutoStep := E_AutoStep.Step_ValveA;
        ELSE
            (* Stop sequence *)
            eAutoStep := E_AutoStep.Step_Idle;
        END_IF;
    END_IF;

    (* Automatic Sequence State Machine *)
    IF xAutoActive AND NOT xLevelSensorFault THEN
        CASE eAutoStep OF
            E_AutoStep.Step_ValveA:
                valveARun := TRUE;
                IF levelSensor >= 50 THEN
                    valveARun := FALSE;
                    eAutoStep := E_AutoStep.Step_ValveB;
                END_IF;

            E_AutoStep.Step_ValveB:
                valveBRun := TRUE;
                IF levelSensor >= 80 THEN
                    valveBRun := FALSE;
                    eAutoStep := E_AutoStep.Step_ProcessBranch;
                END_IF;

            E_AutoStep.Step_ProcessBranch:
                IF NOT processMode THEN
                    (* Simple Mix Path *)
                    mixMotorRun := TRUE;
                    tMixMotorTimer(IN := TRUE, PT := tMixMotorTimeoutTime);
                    IF mixMotorComplete THEN
                        mixMotorRun := FALSE;
                        tMixMotorTimer(IN := FALSE);
                        eAutoStep := E_AutoStep.Step_ValveD;
                    ELSIF tMixMotorTimer.Q THEN
                        (* Watchdog timeout - fault *)
                        mixMotorRun := FALSE;
                        xMixMotorTimeoutFault := TRUE;
                        xAutoActive := FALSE;
                        eAutoStep := E_AutoStep.Step_Idle;
                    END_IF;
                ELSE
                    (* Process with Material C *)
                    valveCRun := TRUE;
                    IF levelSensor >= 100 THEN
                        valveCRun := FALSE;
                        eAutoStep := E_AutoStep.Step_MixMotor;
                    END_IF;
                END_IF;

            E_AutoStep.Step_MixMotor:
                mixMotorRun := TRUE;
                tMixMotorTimer(IN := TRUE, PT := tMixMotorTimeoutTime);
                IF mixMotorComplete THEN
                    mixMotorRun := FALSE;
                    tMixMotorTimer(IN := FALSE);
                    eAutoStep := E_AutoStep.Step_ValveD;
                ELSIF tMixMotorTimer.Q THEN
                    (* Watchdog timeout - fault *)
                    mixMotorRun := FALSE;
                    xMixMotorTimeoutFault := TRUE;
                    xAutoActive := FALSE;
                    eAutoStep := E_AutoStep.Step_Idle;
                END_IF;

            E_AutoStep.Step_ValveD:
                (* Safety Interlock: Ensure all inlet valves are closed before opening outlet *)
                IF NOT valveARun AND NOT valveBRun AND NOT valveCRun THEN
                    valveDRun := TRUE;
                END_IF;
                (* Sequence completes and resets *)
                xAutoActive := FALSE;
                eAutoStep := E_AutoStep.Step_Idle;

        END_CASE;
    ELSE
        (* Auto not active or sensor fault: Deactivate all automatic outputs *)
        valveARun := FALSE;
        valveBRun := FALSE;
        valveCRun := FALSE;
        mixMotorRun := FALSE;
        tMixMotorTimer(IN := FALSE);
        (* Note: valveDRun is not forced FALSE here to allow manual control or completion *)
    END_IF;

    (* In Automatic Mode, manual toggle states are ignored for outputs *)
    xManualValveA := FALSE;
    xManualValveB := FALSE;
    xManualValveC := FALSE;
    xManualValveD := FALSE;
    xManualMixMotor := FALSE;
END_IF; (* End of Mode Selection *)

(*----------------------------------------------------------------------------*)
(* 5. FINAL OUTPUT OVERRIDES & INTERLOCKS                                     *)
(*    Applies final safety and interlocking rules.                            *)
(*----------------------------------------------------------------------------*)
(* Override all outputs if a critical fault is detected *)
IF xLevelSensorFault OR xMixMotorTimeoutFault THEN
    valveARun := FALSE;
    valveBRun := FALSE;
    valveCRun := FALSE;
    mixMotorRun := FALSE;
    (* valveDRun may be left as-is or also forced FALSE depending on safety assessment *)
END_IF;

(* Independent High-Level Overfill Protection (Conceptual) *)
(* This logic represents a software safety layer. For SIL-rated applications,
   this must be implemented in a separate safety PLC or hardwired circuit. *)
IF levelSensor > 105 THEN (* Example high-level trip point *)
    valveARun := FALSE;
    valveBRun := FALSE;
    valveCRun := FALSE;
    mixMotorRun := FALSE;
END_IF;

END_FUNCTION_BLOCK