ructured-text
START_ST
FUNCTION_BLOCK ChargingStationControl
VAR_INPUT
    EVConnected : BOOL; // Input for EV connection status
    EVVoltage : REAL; // Input for EV battery voltage
    EVCurrent : REAL; // Input for EV charging current
    EVStateOfCharge : REAL; // Input for EV state of charge
    ChargingTimer : TIME; // Input for charging time
    MinimumVoltage : REAL; // Minimum acceptable voltage
    MaximumCurrent : REAL; // Maximum acceptable current
    MinimumSOC : REAL; // Minimum state of charge
    ChargingVoltage : REAL; // Charging voltage
    ChargingCurrent : REAL; // Charging current
    MaximumChargingTime : TIME; // Maximum charging time
END_VAR

VAR_OUTPUT
    EVCharging : BOOL; // Output to control EV charging
END_VAR

VAR
    state : INT; // THE STATE VARIABLE
    prevState : INT; // THE PREVIOUS STATE VARIABLE
END_VAR

// State Definitions
CONST
    INITIALIZE : INT := 0;
    CHARGING : INT := 1;
    STOPPED : INT := 2;
END_CONST

// Initialize state
state := INITIALIZE;

// Control Logic
CASE state OF
    INITIALIZE:
        EVCharging := FALSE;
        IF (EVConnected = TRUE) AND (EVVoltage > MinimumVoltage) AND (EVCurrent <= MaximumCurrent) AND (EVStateOfCharge < 100.0) AND (ChargingTimer <= MaximumChargingTime) THEN
            state := CHARGING;
        END_IF;

    CHARGING:
        EVCharging := TRUE;
        IF (EVConnected = FALSE) OR (EVVoltage <= MinimumVoltage) OR (EVCurrent > MaximumCurrent) OR (EVStateOfCharge >= 100.0) OR (ChargingTimer > MaximumChargingTime) THEN
            state := STOPPED;
        END_IF;

    STOPPED:
        EVCharging := FALSE;
        IF (EVConnected = TRUE) AND (EVVoltage > MinimumVoltage) AND (EVCurrent <= MaximumCurrent) AND (EVStateOfCharge < 100.0) AND (ChargingTimer <= MaximumChargingTime) THEN
            state := CHARGING;
        ELSE
            state := INITIALIZE;
        END_IF;

END_CASE;

END_FUNCTION_BLOCK
END_ST