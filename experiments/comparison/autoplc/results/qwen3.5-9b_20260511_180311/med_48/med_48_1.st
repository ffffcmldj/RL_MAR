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
    StopCondition : BOOL;
    StartCondition : BOOL;
    i : INT;
    ConditionCount : INT;
    TotalConditions : INT;
END_VAR

StopCondition := NOT EVConnected OR EVVoltage <= MinimumVoltage OR EVCurrent > MaximumCurrent OR EVStateOfCharge >= 100.0 OR ChargingTimer > MaximumChargingTime;

IF StopCondition THEN
    EVCharging := FALSE;
ELSE
    StartCondition := EVConnected AND EVVoltage > MinimumVoltage AND EVCurrent <= MaximumCurrent AND EVStateOfCharge < 100.0 AND ChargingTimer <= MaximumChargingTime;
    
    IF StartCondition THEN
        EVCharging := TRUE;
    ELSE
        EVCharging := FALSE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK