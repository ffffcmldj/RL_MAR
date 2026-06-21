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
    StartChargingConditionsMet : BOOL;
    StopChargingConditionsMet : BOOL;
END_VAR

// Initialization
StartChargingConditionsMet := FALSE;
StopChargingConditionsMet := FALSE;

// Continuous Monitoring and State Evaluation
IF EVConnected THEN
    IF (EVVoltage > MinimumVoltage) AND 
       (EVCurrent <= MaximumCurrent) AND 
       (EVStateOfCharge < 100.0) AND 
       (ChargingTimer <= MaximumChargingTime) THEN
        StartChargingConditionsMet := TRUE;
    END_IF;
ELSE
    StopChargingConditionsMet := TRUE;
END_IF;

IF (EVVoltage <= MinimumVoltage) OR 
   (EVCurrent > MaximumCurrent) OR 
   (EVStateOfCharge >= 100.0) OR 
   (ChargingTimer > MaximumChargingTime) THEN
    StopChargingConditionsMet := TRUE;
END_IF;

// Output Update
IF StartChargingConditionsMet AND NOT StopChargingConditionsMet THEN
    EVCharging := TRUE;
ELSE
    EVCharging := FALSE;
END_IF;

END_FUNCTION_BLOCK