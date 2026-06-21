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
    bStopCondition : BOOL;
    bStartCondition : BOOL;
END_VAR

(* Evaluate stop conditions - any TRUE condition will stop charging *)
bStopCondition := FALSE;

IF NOT EVConnected THEN
    bStopCondition := TRUE;
ELSIF EVVoltage <= MinimumVoltage THEN
    bStopCondition := TRUE;
ELSIF EVCurrent > MaximumCurrent THEN
    bStopCondition := TRUE;
ELSIF EVStateOfCharge >= 100.0 THEN
    bStopCondition := TRUE;
ELSIF ChargingTimer > MaximumChargingTime THEN
    bStopCondition := TRUE;
END_IF;

(* If any stop condition is met, stop charging immediately *)
IF bStopCondition THEN
    EVCharging := FALSE;
ELSE
    (* Evaluate start conditions - all must be TRUE to start charging *)
    bStartCondition := TRUE;
    
    IF NOT EVConnected THEN
        bStartCondition := FALSE;
    END_IF;
    
    IF EVVoltage <= MinimumVoltage THEN
        bStartCondition := FALSE;
    END_IF;
    
    IF EVCurrent > MaximumCurrent THEN
        bStartCondition := FALSE;
    END_IF;
    
    IF EVStateOfCharge >= 100.0 THEN
        bStartCondition := FALSE;
    END_IF;
    
    IF ChargingTimer > MaximumChargingTime THEN
        bStartCondition := FALSE;
    END_IF;
    
    (* Additional condition: EVVoltage must be above minimum (strictly greater) *)
    IF EVVoltage <= MinimumVoltage THEN
        bStartCondition := FALSE;
    END_IF;
    
    (* Set charging state based on start conditions *)
    EVCharging := bStartCondition;
END_IF;

END_FUNCTION_BLOCK