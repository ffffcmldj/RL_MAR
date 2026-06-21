ructured-text
START_ST
FUNCTION_BLOCK ChargingStationControl
VAR_INPUT
    EVConnected : BOOL; // INPUT FOR EV CONNECTION STATUS
    EVVoltage : REAL; // INPUT FOR EV BATTERY VOLTAGE
    EVCurrent : REAL; // INPUT FOR EV CHARGING CURRENT
    EVStateOfCharge : REAL; // INPUT FOR EV STATE OF CHARGE
    ChargingTimer : TIME; // INPUT FOR CHARGING TIMER
END_VAR

VAR_OUTPUT
    EVCharging : BOOL; // OUTPUT TO CONTROL EV CHARGING
END_VAR

VAR
    VoltageOK : BOOL; // INTERMEDIATE VARIABLE FOR VOLTAGE CHECK
    CurrentOK : BOOL; // INTERMEDIATE VARIABLE FOR CURRENT CHECK
    SOCNotFull : BOOL; // INTERMEDIATE VARIABLE FOR STATE OF CHARGE CHECK
    TimerOK : BOOL; // INTERMEDIATE VARIABLE FOR TIMER CHECK
    state : INT; // THE STATE VARIABLE
    prevState : INT; // THE PREVIOUS STATE VARIABLE
END_VAR

// INITIALIZE STATE
state := 0;
prevState := 0;

// CHECK CONDITIONS
VoltageOK := (EVVoltage > 350.0);
CurrentOK := (EVCurrent <= 32.0);
SOCNotFull := (EVStateOfCharge < 100.0);
TimerOK := (ChargingTimer <= T#2h);

// STATE MACHINE LOGIC
CASE state OF
    0: // INITIALIZE STATE
        EVCharging := FALSE;
        IF (EVConnected AND VoltageOK AND CurrentOK AND SOCNotFull AND TimerOK) THEN
            state := 1; // Transition to CHARGING
        END_IF;
        
    1: // CHARGING STATE
        EVCharging := TRUE;
        IF NOT (EVConnected AND VoltageOK AND CurrentOK AND SOCNotFull AND TimerOK) THEN
            state := 2; // Transition to NOT CHARGING
        END_IF;

    2: // NOT CHARGING STATE
        EVCharging := FALSE;
        IF (EVConnected AND VoltageOK AND CurrentOK AND SOCNotFull AND TimerOK) THEN
            state := 0; // Transition to INITIALIZE
        END_IF;

END_CASE;

prevState := state; // Update previous state

END_FUNCTION_BLOCK
END_ST