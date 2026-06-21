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

(* Initialization of output variables *)
OxygenValve := FALSE;
Heater := FALSE;
Feeder := FALSE;

(* Oxygen Control Logic *)
IF OxygenLevel < 5.0 THEN
    OxygenValve := TRUE; (* Open the oxygen valve *)
ELSE
    OxygenValve := FALSE; (* Close the oxygen valve *)
END_IF;

(* Temperature Control Logic *)
IF WaterTemperature < 25.0 THEN
    Heater := TRUE; (* Turn on the heater *)
ELSE
    Heater := FALSE; (* Turn off the heater *)
END_IF;

(* Feeding Control Logic *)
IF CurrentTime >= FeedingTime THEN
    Feeder := TRUE; (* Activate the feeder *)
ELSE
    Feeder := FALSE; (* Deactivate the feeder *)
END_IF;

END_FUNCTION_BLOCK