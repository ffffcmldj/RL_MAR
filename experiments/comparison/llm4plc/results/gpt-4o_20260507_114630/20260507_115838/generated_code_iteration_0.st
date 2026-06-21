plaintext
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
    VoltageOK : BOOL;
    CurrentOK : BOOL;
    SOCNotFull : BOOL;
    TimerOK : BOOL;
    state : INT; // 0 = IDLE, 1 = START_CHARGING, 2 = STOP_CHARGING
END_VAR

// Evaluate conditions
VoltageOK := EVVoltage > 350.0;
CurrentOK := EVCurrent <= 32.0;
SOCNotFull := EVStateOfCharge < 100.0;
TimerOK := ChargingTimer <= T#2h;

// State Machine Logic
CASE state OF
    0: // IDLE
        EVCharging := FALSE;
        IF EVConnected AND VoltageOK AND CurrentOK AND SOCNotFull AND TimerOK THEN
            state := 1; // Transition to START_CHARGING
        END_IF;

    1: // START_CHARGING
        EVCharging := TRUE;
        IF NOT EVConnected OR NOT VoltageOK OR NOT CurrentOK OR NOT SOCNotFull OR NOT TimerOK THEN
            state := 2; // Transition to STOP_CHARGING
        END_IF;

    2: // STOP_CHARGING
        EVCharging := FALSE;
        state := 0; // Transition back to IDLE
END_CASE;

END_FUNCTION_BLOCK
END_ST