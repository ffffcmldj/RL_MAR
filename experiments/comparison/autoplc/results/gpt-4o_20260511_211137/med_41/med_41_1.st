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
    (* Internal variables can be declared here if needed *)
END_VAR

(* Control logic for Oxygen Valve *)
IF OxygenLevel < 5.0 THEN
    OxygenValve := TRUE; (* Open the oxygen valve *)
ELSE
    OxygenValve := FALSE; (* Close the oxygen valve *)
END_IF

(* Control logic for Heater *)
IF WaterTemperature < 25.0 THEN
    Heater := TRUE; (* Activate the heater *)
ELSE
    Heater := FALSE; (* Deactivate the heater *)
END_IF

(* Control logic for Feeder *)
IF CurrentTime >= FeedingTime THEN
    Feeder := TRUE; (* Operate the feeder *)
ELSE
    Feeder := FALSE; (* Disable the feeder *)
END_IF

END_FUNCTION_BLOCK