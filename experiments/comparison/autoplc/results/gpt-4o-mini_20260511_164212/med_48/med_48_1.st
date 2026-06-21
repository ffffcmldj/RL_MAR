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

// Initialization of EVCharging
EVCharging := FALSE;

// Condition Evaluation
IF EVConnected THEN
    IF (EVVoltage > MinimumVoltage) AND 
       (EVCurrent <= MaximumCurrent) AND 
       (EVStateOfCharge < 100.0) AND 
       (ChargingTimer <= MaximumChargingTime) THEN
        // All conditions to start charging are met
        EVCharging := TRUE;
    ELSE
        // Any condition to stop charging is met
        EVCharging := FALSE;
    END_IF;
ELSE
    // EV is disconnected
    EVCharging := FALSE;
END_IF;

END_FUNCTION_BLOCK