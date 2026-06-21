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
    (* No internal variables required for basic threshold logic *)
END_VAR

(* Control logic for Oxygen Valve *)
IF OxygenLevel < 5.0 THEN
    OxygenValve := TRUE;
ELSE
    OxygenValve := FALSE;
END_IF;

(* Control logic for Heater *)
IF WaterTemperature < 25.0 THEN
    Heater := TRUE;
ELSE
    Heater := FALSE;
END_IF;

(* Control logic for Feeder *)
IF CurrentTime >= FeedingTime THEN
    Feeder := TRUE;
ELSE
    Feeder := FALSE;
END_IF;

END_FUNCTION_BLOCK