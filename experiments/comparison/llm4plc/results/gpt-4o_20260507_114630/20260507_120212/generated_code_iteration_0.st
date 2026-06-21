plaintext
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
    State : INT; (* The current state of the FSM *)
END_VAR

(* Initialization of the FSM state *)
IF State = 0 THEN
    (* STATE 0: IDLE *)
    OxygenValve := FALSE; (* Turn off oxygen valve *)
    Heater := FALSE; (* Turn off heater *)
    Feeder := FALSE; (* Turn off feeder *)
    State := 1; (* Transition to STATE 1: REGULATE OXYGEN *)
ELSIF State = 1 THEN
    (* STATE 1: REGULATE OXYGEN *)
    IF OxygenLevel < 5.0 THEN
        OxygenValve := TRUE; (* Open oxygen valve *)
    ELSE
        OxygenValve := FALSE; (* Close oxygen valve *)
    END_IF;
    State := 2; (* Transition to STATE 2: REGULATE TEMPERATURE *)
ELSIF State = 2 THEN
    (* STATE 2: REGULATE TEMPERATURE *)
    IF WaterTemperature < 25.0 THEN
        Heater := TRUE; (* Turn on heater *)
    ELSE
        Heater := FALSE; (* Turn off heater *)
    END_IF;
    State := 3; (* Transition to STATE 3: FEED FISH *)
ELSIF State = 3 THEN
    (* STATE 3: FEED FISH *)
    IF CurrentTime >= FeedingTime THEN
        Feeder := TRUE; (* Activate feeder *)
    ELSE
        Feeder := FALSE; (* Deactivate feeder *)
    END_IF;
    State := 0; (* Transition back to STATE 0: IDLE *)
END_IF;

END_FUNCTION_BLOCK
END_ST