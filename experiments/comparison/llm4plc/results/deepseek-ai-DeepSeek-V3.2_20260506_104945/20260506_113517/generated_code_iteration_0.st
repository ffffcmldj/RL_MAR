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
    state : INT; // 0 = IDLE, 1 = CHARGING
    prevState : INT;
    VoltageOK : BOOL;
    CurrentOK : BOOL;
    SOCNotFull : BOOL;
    TimerOK : BOOL;
    AllStartConditions : BOOL;
    AnyStopCondition : BOOL;
    bFirstScan : BOOL := TRUE;
END_VAR

// Initialization on first scan
IF bFirstScan THEN
    state := 0; // IDLE
    prevState := 0;
    bFirstScan := FALSE;
END_IF;

// Store previous state for monitoring/debugging
prevState := state;

// Calculate intermediate condition variables
VoltageOK := EVVoltage > 350.0;
CurrentOK := EVCurrent <= 32.0;
SOCNotFull := EVStateOfCharge < 100.0;
TimerOK := ChargingTimer <= T#2h;

// Calculate combined conditions
AllStartConditions := EVConnected AND VoltageOK AND CurrentOK AND SOCNotFull AND TimerOK;
AnyStopCondition := (NOT EVConnected) OR (NOT VoltageOK) OR (NOT CurrentOK) OR (NOT SOCNotFull) OR (NOT TimerOK);

// Finite State Machine (FSM) logic
CASE state OF
    0: // IDLE state
        IF AllStartConditions THEN
            state := 1; // Transition to CHARGING
        END_IF;
        EVCharging := FALSE;

    1: // CHARGING state
        IF AnyStopCondition THEN
            state := 0; // Transition to IDLE
        END_IF;
        EVCharging := TRUE;

    ELSE
        // Fallback: reset to IDLE state
        state := 0;
        EVCharging := FALSE;
END_CASE;

END_FUNCTION_BLOCK
END_ST