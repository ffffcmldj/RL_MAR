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
    (* No internal variables are required as per the plan:
       The logic is purely reactive and evaluated directly from inputs
       in every scan cycle without state retention. *)
END_VAR

    (* STATE 0: REACTIVE_CONTROL *)
    (* Logic: Evaluate conditions directly and set outputs *)
    
    (* Condition: Oxygen valve opens when oxygen level drops below 5.0 *)
    IF OxygenLevel < 5.0 THEN
        OxygenValve := TRUE;
    ELSE
        OxygenValve := FALSE;
    END_IF;

    (* Condition: Heater activates when water temperature is below 25.0°C *)
    IF WaterTemperature < 25.0 THEN
        Heater := TRUE;
    ELSE
        Heater := FALSE;
    END_IF;

    (* Condition: Feeder operates when current time is equal to or surpasses feeding time *)
    IF CurrentTime >= FeedingTime THEN
        Feeder := TRUE;
    ELSE
        Feeder := FALSE;
    END_IF;

END_FUNCTION_BLOCK
END_ST