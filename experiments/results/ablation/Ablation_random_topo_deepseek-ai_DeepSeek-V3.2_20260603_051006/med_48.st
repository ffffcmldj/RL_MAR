FUNCTION_BLOCK ChargingStationControl
VAR_INPUT
    EVConnected : BOOL;
    EVVoltage : REAL;
    EVCurrent : REAL;
    EVStateOfCharge : REAL;
    ChargingTimer : TIME;
    MinimumVoltage : REAL;
    MaximumCurrent : REAL;
    MinimumSOC : REAL;
    ChargingVoltage : REAL;
    ChargingCurrent : REAL;
    MaximumChargingTime : TIME;
END_VAR

VAR_OUTPUT
    EVCharging : BOOL;
END_VAR

VAR
    bStartConditionsMet : BOOL;
    bStopConditionsMet : BOOL;
END_VAR

(* Evaluate start conditions - ALL must be TRUE to start charging *)
bStartConditionsMet := EVConnected 
    AND (EVVoltage > MinimumVoltage) 
    AND (EVCurrent <= MaximumCurrent) 
    AND (EVStateOfCharge < 100.0) 
    AND (ChargingTimer <= MaximumChargingTime);

(* Evaluate stop conditions - ANY condition being TRUE stops charging *)
bStopConditionsMet := (NOT EVConnected) 
    OR (EVVoltage <= MinimumVoltage) 
    OR (EVCurrent > MaximumCurrent) 
    OR (EVStateOfCharge >= 100.0) 
    OR (ChargingTimer > MaximumChargingTime);

(* Main control logic *)
IF bStartConditionsMet AND NOT bStopConditionsMet THEN
    EVCharging := TRUE;
ELSE
    EVCharging := FALSE;
END_IF;

END_FUNCTION_BLOCK