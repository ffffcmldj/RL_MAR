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

// Function block code
VAR
    MinimumVoltage : REAL := 350.0;
    MaximumCurrent : REAL := 32.0;
    MaximumChargingTime : TIME := T#2h;
END_VAR

// Initialization and condition evaluation
VoltageOK := (EVVoltage > MinimumVoltage);
CurrentOK := (EVCurrent <= MaximumCurrent);
SOCNotFull := (EVStateOfCharge < 100.0);
TimerOK := (ChargingTimer <= MaximumChargingTime);

// Control logic execution
IF EVConnected AND VoltageOK AND CurrentOK AND SOCNotFull AND TimerOK THEN
    EVCharging := TRUE;
ELSE
    EVCharging := FALSE;
END_IF

END_FUNCTION_BLOCK