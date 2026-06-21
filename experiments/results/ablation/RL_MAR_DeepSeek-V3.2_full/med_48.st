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
    bStopConditionActive : BOOL;
END_VAR

    (* Evaluate all start conditions simultaneously *)
    bStartConditionsMet := EVConnected 
        AND (EVVoltage > MinimumVoltage) 
        AND (EVCurrent <= MaximumCurrent) 
        AND (EVStateOfCharge < 100.0) 
        AND (ChargingTimer <= MaximumChargingTime);
    
    (* Evaluate stop conditions - any single condition stops charging *)
    bStopConditionActive := NOT EVConnected 
        OR (EVVoltage <= MinimumVoltage) 
        OR (EVCurrent > MaximumCurrent) 
        OR (EVStateOfCharge >= 100.0) 
        OR (ChargingTimer > MaximumChargingTime);
    
    (* Final charging decision: start conditions met AND no stop conditions active *)
    EVCharging := bStartConditionsMet AND NOT bStopConditionActive;

END_FUNCTION_BLOCK;