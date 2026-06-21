FUNCTION_BLOCK ChargingStationControl
VAR_INPUT
    EVConnected : BOOL;
    EVVoltage : REAL;
    EVCurrent : REAL;
    EVStateOfCharge : REAL;
    ChargingTimer : TIME;
END_VAR

VAR_OUTPUT
    EVCharging : BOOL;
END_VAR

VAR
    VoltageOK : BOOL;
    CurrentOK : BOOL;
    SOCNotFull : BOOL;
    TimerOK : BOOL;
END_VAR

// Initialization
EVCharging := FALSE;

// Condition Evaluation
IF EVVoltage > 350.0 THEN
    VoltageOK := TRUE;
ELSE
    VoltageOK := FALSE;
END_IF;

IF EVCurrent <= 32.0 THEN
    CurrentOK := TRUE;
ELSE
    CurrentOK := FALSE;
END_IF;

IF EVStateOfCharge < 100.0 THEN
    SOCNotFull := TRUE;
ELSE
    SOCNotFull := FALSE;
END_IF;

IF ChargingTimer <= T#2h THEN
    TimerOK := TRUE;
ELSE
    TimerOK := FALSE;
END_IF;

// Charging Control Logic
IF EVConnected AND VoltageOK AND CurrentOK AND SOCNotFull AND TimerOK THEN
    EVCharging := TRUE; // Start charging
ELSE
    EVCharging := FALSE; // Stop charging
END_IF;

END_FUNCTION_BLOCK