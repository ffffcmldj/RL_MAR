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

    // Evaluate voltage condition
    IF EVVoltage > 350.0 THEN
        VoltageOK := TRUE;
    ELSE
        VoltageOK := FALSE;
    END_IF;
    
    // Evaluate current condition
    IF EVCurrent <= 32.0 THEN
        CurrentOK := TRUE;
    ELSE
        CurrentOK := FALSE;
    END_IF;
    
    // Evaluate state of charge condition
    IF EVStateOfCharge < 100.0 THEN
        SOCNotFull := TRUE;
    ELSE
        SOCNotFull := FALSE;
    END_IF;
    
    // Evaluate timer condition
    IF ChargingTimer <= T#2h THEN
        TimerOK := TRUE;
    ELSE
        TimerOK := FALSE;
    END_IF;
    
    // Determine charging state based on all conditions
    IF EVConnected AND VoltageOK AND CurrentOK AND SOCNotFull AND TimerOK THEN
        EVCharging := TRUE;
    ELSE
        EVCharging := FALSE;
    END_IF;

END_FUNCTION_BLOCK