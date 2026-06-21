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
    state : INT; (* 0 = IDLE, 1 = CHARGING *)
    prevState : INT;
    startConditionsMet : BOOL;
    stopConditionsMet : BOOL;
END_VAR
    (* Store previous state for reference *)
    prevState := state;

    (* Evaluate all start conditions *)
    startConditionsMet := EVConnected
        AND (EVVoltage > MinimumVoltage)
        AND (EVCurrent <= MaximumCurrent)
        AND (EVStateOfCharge < 100.0)
        AND (ChargingTimer <= MaximumChargingTime);

    (* Evaluate all stop conditions *)
    stopConditionsMet := (NOT EVConnected)
        OR (EVVoltage <= MinimumVoltage)
        OR (EVCurrent > MaximumCurrent)
        OR (EVStateOfCharge >= 100.0)
        OR (ChargingTimer > MaximumChargingTime);

    (* State machine logic *)
    CASE state OF
        0: (* IDLE state *)
            IF startConditionsMet THEN
                state := 1; (* Transition to CHARGING *)
            END_IF;

        1: (* CHARGING state *)
            IF stopConditionsMet THEN
                state := 0; (* Transition to IDLE *)
            END_IF;

        ELSE
            (* Default case: reset to IDLE if state is invalid *)
            state := 0;
    END_CASE;

    (* Set output based on current state *)
    EVCharging := (state = 1);
END_FUNCTION_BLOCK
END_ST