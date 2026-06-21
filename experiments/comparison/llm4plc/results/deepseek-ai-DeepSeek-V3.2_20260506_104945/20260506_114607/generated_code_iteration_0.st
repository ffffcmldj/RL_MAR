START_ST
FUNCTION_BLOCK FishTankControl
VAR_INPUT
    OxygenLevel : REAL; (* Input for oxygen level in the tank *)
    WaterTemperature : REAL; (* Input for water temperature *)
    FeedingTime : TIME; (* Time for scheduled feeding *)
    CurrentTime : TIME; (* Current system time *)
END_VAR
VAR_OUTPUT
    OxygenValve : BOOL; (* Output to control oxygen supply *)
    Heater : BOOL; (* Output to control the heater *)
    Feeder : BOOL; (* Output to control the fish feeder *)
END_VAR
VAR
    state : INT; (* Current state: 0=IDLE, 1=OXYGEN_SUPPLY_ACTIVE, 2=HEATER_ACTIVE, 3=FEEDER_ACTIVE *)
    prevState : INT; (* Previous state for tracking *)
    feedingActive : BOOL; (* Internal flag to indicate feeding is in progress *)
    feedStartTime : TIME; (* Time when feeding started *)
    feedDuration : TIME := T#5S; (* Assumed feeding duration - adjust as needed *)
END_VAR

(* State machine initialization *)
IF prevState = 0 THEN
    state := 0;
    prevState := -1;
    feedingActive := FALSE;
    feedStartTime := T#0s;
END_IF;

(* State transitions and output logic *)
CASE state OF
    0: (* IDLE - Monitoring *)
        OxygenValve := FALSE;
        Heater := FALSE;
        Feeder := FALSE;
        
        (* Check transitions from IDLE state *)
        IF OxygenLevel < 5.0 THEN
            state := 1; (* Transition to OXYGEN_SUPPLY_ACTIVE *)
        ELSIF WaterTemperature < 25.0 THEN
            state := 2; (* Transition to HEATER_ACTIVE *)
        ELSIF (CurrentTime >= FeedingTime) AND NOT feedingActive THEN
            state := 3; (* Transition to FEEDER_ACTIVE *)
            feedingActive := TRUE;
            feedStartTime := CurrentTime;
        END_IF;
        
    1: (* OXYGEN_SUPPLY_ACTIVE *)
        OxygenValve := TRUE;
        Heater := FALSE;
        Feeder := FALSE;
        
        (* Check transition back to IDLE *)
        IF OxygenLevel >= 5.0 THEN
            state := 0;
        END_IF;
        
    2: (* HEATER_ACTIVE *)
        OxygenValve := FALSE;
        Heater := TRUE;
        Feeder := FALSE;
        
        (* Check transition back to IDLE *)
        IF WaterTemperature >= 25.0 THEN
            state := 0;
        END_IF;
        
    3: (* FEEDER_ACTIVE *)
        OxygenValve := FALSE;
        Heater := FALSE;
        Feeder := TRUE;
        
        (* Check if feeding duration has elapsed *)
        IF (CurrentTime - feedStartTime) >= feedDuration THEN
            state := 0;
            feedingActive := FALSE;
            Feeder := FALSE;
        END_IF;
        
END_CASE;

(* Update previous state for next cycle *)
prevState := state;

END_FUNCTION_BLOCK
END_ST