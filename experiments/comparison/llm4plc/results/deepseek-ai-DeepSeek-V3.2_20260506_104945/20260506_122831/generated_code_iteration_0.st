START_ST
FUNCTION_BLOCK BakeryOvenControl
VAR_INPUT
    TemperatureSensor : REAL; (* Sensor input for oven temperature *)
    HumiditySensor : REAL; (* Sensor input for oven humidity *)
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL; (* Control signal for heating element *)
    CoolingElement : BOOL; (* Control signal for cooling element *)
    HumidityControl : BOOL; (* Control signal for humidity system *)
    DehumidityControl : BOOL; (* Control signal for dehumidification *)
END_VAR
VAR
    (* State machine variables *)
    state : INT := 0; (* Current state: 0=OVEN_OFF, 1=OVEN_ON_BAKING, 2=BAKING_COMPLETE *)
    prevState : INT := 0; (* Previous state for debugging or edge detection *)

    (* Setpoints and thresholds - configurable when oven is off *)
    OvenTemperature : REAL := 0.0; (* Current oven temperature setpoint *)
    OvenHumidity : REAL := 0.0; (* Current oven humidity setpoint *)
    BakingTime : TIME := T#0s; (* Baking time setpoint *)
    OvenStatus : BOOL := FALSE; (* Oven status: TRUE=On, FALSE=Off *)
    HeatingThreshold : REAL := 2.0; (* Temperature control threshold *)
    HumidityThreshold : REAL := 5.0; (* Humidity control threshold *)

    (* Timer variables for 1-second decrement *)
    lastTime : TIME; (* Variable to store the last time for interval calculation *)
    timerDecrement : TIME; (* Internal variable to track elapsed time *)

    (* Edge detection for OvenStatus *)
    prevOvenStatus : BOOL := FALSE; (* Previous OvenStatus for edge detection *)
END_VAR

(* Main state machine logic *)
prevState := state; (* Store previous state for reference *)

(* State transitions *)
CASE state OF
    0: (* STATE 0: OVEN_OFF *)
        (* Transition to STATE 1 when OvenStatus changes from FALSE to TRUE *)
        IF (OvenStatus = TRUE) AND (prevOvenStatus = FALSE) THEN
            state := 1; (* Move to baking state *)
        END_IF;

    1: (* STATE 1: OVEN_ON_BAKING *)
        (* Transition to STATE 2 when BakingTime reaches zero or below *)
        IF BakingTime <= T#0s THEN
            state := 2; (* Move to baking complete state *)
        END_IF;
        
        (* Transition back to STATE 0 if OvenStatus is set to FALSE (abort operation) *)
        IF OvenStatus = FALSE THEN
            state := 0;
        END_IF;

    2: (* STATE 2: BAKING_COMPLETE *)
        (* Transition to STATE 0 when OvenStatus is set to FALSE *)
        IF OvenStatus = FALSE THEN
            state := 0;
        END_IF;
END_CASE;

(* Update edge detection variable *)
prevOvenStatus := OvenStatus;

(* State actions and output control *)
CASE state OF
    0: (* STATE 0: OVEN_OFF *)
        (* All outputs are off in off state *)
        HeatingElement := FALSE;
        CoolingElement := FALSE;
        HumidityControl := FALSE;
        DehumidityControl := FALSE;
        
        (* Reset timer variables when in off state *)
        lastTime := TIME(); (* Get current time *)
        timerDecrement := T#0s;

    1: (* STATE 1: OVEN_ON_BAKING *)
        (* Temperature control logic *)
        IF (TemperatureSensor < (OvenTemperature - HeatingThreshold)) AND OvenStatus = TRUE THEN
            HeatingElement := TRUE;
            CoolingElement := FALSE;
        ELSIF (TemperatureSensor > (OvenTemperature + HeatingThreshold)) AND OvenStatus = TRUE THEN
            HeatingElement := FALSE;
            CoolingElement := TRUE;
        ELSE
            HeatingElement := FALSE;
            CoolingElement := FALSE;
        END_IF;

        (* Humidity control logic *)
        IF (HumiditySensor < (OvenHumidity - HumidityThreshold)) AND OvenStatus = TRUE THEN
            HumidityControl := TRUE;
            DehumidityControl := FALSE;
        ELSIF (HumiditySensor > (OvenHumidity + HumidityThreshold)) AND OvenStatus = TRUE THEN
            HumidityControl := FALSE;
            DehumidityControl := TRUE;
        ELSE
            HumidityControl := FALSE;
            DehumidityControl := FALSE;
        END_IF;

        (* Baking timer decrement logic - decrement every 1 second *)
        timerDecrement := TIME() - lastTime; (* Calculate elapsed time *)
        
        IF timerDecrement >= T#1s THEN
            (* Decrement BakingTime by 1 second *)
            IF BakingTime > T#0s THEN
                BakingTime := BakingTime - T#1s;
            ELSE
                BakingTime := T#0s; (* Ensure it doesn't go negative *)
            END_IF;
            
            (* Reset timer for next 1-second interval *)
            lastTime := TIME();
            timerDecrement := T#0s;
        END_IF;

    2: (* STATE 2: BAKING_COMPLETE *)
        (* All outputs are off when baking is complete *)
        HeatingElement := FALSE;
        CoolingElement := FALSE;
        HumidityControl := FALSE;
        DehumidityControl := FALSE;
        
        (* Ensure BakingTime is zero *)
        BakingTime := T#0s;
END_CASE;

END_FUNCTION_BLOCK
END_ST