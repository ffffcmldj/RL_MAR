START_ST
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
    CurrentState : INT; // 0 = IDLE, 1 = ACTIVE
    NextState : INT;
    StartCondition : BOOL;
    StopCondition : BOOL;
END_VAR

// Initialize state on first execution (simulated via state change logic)
// In a real implementation, an INIT flag or static variable would be preferred,
// but we follow the FSM structure defined in the plan.
IF CurrentState = 0 AND NOT EVConnected THEN
    CurrentState := 0;
ELSIF CurrentState = 0 AND EVConnected THEN
    // Evaluate Start Conditions
    StartCondition := (EVConnected = TRUE) AND
                      (EVVoltage > MinimumVoltage) AND
                      (EVCurrent <= MaximumCurrent) AND
                      (EVStateOfCharge < 100.0) AND
                      (ChargingTimer <= MaximumChargingTime);

    IF StartCondition THEN
        NextState := 1;
    ELSE
        NextState := 0;
    END_IF;
ELSIF CurrentState = 1 THEN
    // Evaluate Stop Conditions
    StopCondition := (EVConnected = FALSE) OR
                      (EVVoltage <= MinimumVoltage) OR
                      (EVCurrent > MaximumCurrent) OR
                      (EVStateOfCharge >= 100.0) OR
                      (ChargingTimer > MaximumChargingTime);

    IF StopCondition THEN
        NextState := 0;
    ELSE
        NextState := 1;
    END_IF;
END_IF;

// Update state and output
CurrentState := NextState;

// Set output based on current state
IF CurrentState = 1 THEN
    EVCharging := TRUE;
ELSE
    EVCharging := FALSE;
END_IF;

END_FUNCTION_BLOCK
END_ST