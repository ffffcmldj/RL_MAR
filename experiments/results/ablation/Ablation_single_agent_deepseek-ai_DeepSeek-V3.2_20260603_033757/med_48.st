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

(* Check if all start conditions are met *)
bStartConditionsMet := EVConnected 
    AND (EVVoltage > MinimumVoltage) 
    AND (EVCurrent <= MaximumCurrent) 
    AND (EVStateOfCharge < 100.0) 
    AND (ChargingTimer <= MaximumChargingTime);

(* Check if any stop condition is met *)
bStopConditionsMet := (NOT EVConnected) 
    OR (EVVoltage <= MinimumVoltage) 
    OR (EVCurrent > MaximumCurrent) 
    OR (EVStateOfCharge >= 100.0) 
    OR (ChargingTimer > MaximumChargingTime);

(* Control charging output *)
IF bStartConditionsMet AND NOT bStopConditionsMet THEN
    EVCharging := TRUE;
ELSE
    EVCharging := FALSE;
END_IF;

END_FUNCTION_BLOCK