plaintext
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
    state : INT := 0; // Current state of the FSM (0 for IDLE, 1 for CHARGING)
    prevState : INT := 0; // Previous state of the FSM (for debugging or tracking)
END_VAR

// FSM Logic Implementation
IF state = 0 THEN // STATE 0: IDLE
    // Output for IDLE state
    EVCharging := FALSE;

    // Transition to STATE 1 (CHARGING) if all conditions are met
    IF (EVConnected = TRUE) AND 
       (EVVoltage > MinimumVoltage) AND 
       (EVCurrent <= MaximumCurrent) AND 
       (EVStateOfCharge < 100.0) AND 
       (ChargingTimer <= MaximumChargingTime) THEN
        prevState := state; // Update previous state
        state := 1; // Transition to CHARGING state
    END_IF;

ELSIF state = 1 THEN // STATE 1: CHARGING
    // Output for CHARGING state
    EVCharging := TRUE;

    // Transition to STATE 0 (IDLE) if any condition is met
    IF (EVConnected = FALSE) OR 
       (EVVoltage <= MinimumVoltage) OR 
       (EVCurrent > MaximumCurrent) OR 
       (EVStateOfCharge >= 100.0) OR 
       (ChargingTimer > MaximumChargingTime) THEN
        prevState := state; // Update previous state
        state := 0; // Transition to IDLE state
    END_IF;

END_IF;

END_FUNCTION_BLOCK
END_ST