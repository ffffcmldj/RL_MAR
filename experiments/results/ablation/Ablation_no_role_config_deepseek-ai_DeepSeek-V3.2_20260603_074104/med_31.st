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

(* Evaluate individual conditions *)
VoltageOK := (EVVoltage > 350.0);
CurrentOK := (EVCurrent <= 32.0);
SOCNotFull := (EVStateOfCharge < 100.0);
TimerOK := (ChargingTimer <= T#2h);

(* Main charging control logic *)
IF EVConnected AND VoltageOK AND CurrentOK AND SOCNotFull AND TimerOK THEN
    EVCharging := TRUE;
ELSE
    EVCharging := FALSE;
END_IF;

END_FUNCTION_BLOCK