START_ST
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
    state : INT;
    VoltageOK : BOOL;
    CurrentOK : BOOL;
    SOCNotFull : BOOL;
    TimerOK : BOOL;
END_VAR

END_VAR

END_FUNCTION_BLOCK
END_ST