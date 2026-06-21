FUNCTION_BLOCK GreenhouseWateringSystem
    VAR_INPUT
        SoilMoistureSensor : REAL;   (* Input for soil moisture level (0-100%) *)
        ResponseDelay : TIME := T#5s;  (* Example response delay for the system *)
    END_VAR

    VAR_OUTPUT
        SprinklersOn : BOOL := FALSE;         (* Output for controlling sprinklers - on/off *)
    END_VAR

    VAR
        LastMoistureReading : REAL;
        DelayTimer : TON;
        DelayActive : BOOL;
    END_VAR

    (* Store the current moisture reading *)
    LastMoistureReading := SoilMoistureSensor;

    (* Timer logic for response delay *)
    DelayTimer(
        IN := DelayActive,
        PT := ResponseDelay
    );

    (* Main control logic with hysteresis and delay consideration *)
    IF NOT DelayTimer.Q THEN
        (* Timer not yet elapsed - maintain current state *)
        IF DelayActive THEN
            (* Delay in progress - keep sprinklers in their current state *)
            SprinklersOn := SprinklersOn;
        ELSE
            (* No delay active - evaluate moisture thresholds *)
            IF SoilMoistureSensor < 30.0 THEN
                IF NOT SprinklersOn THEN
                    DelayActive := TRUE;
                END_IF;
                SprinklersOn := TRUE;
            ELSIF SoilMoistureSensor > 70.0 THEN
                IF SprinklersOn THEN
                    DelayActive := TRUE;
                END_IF;
                SprinklersOn := FALSE;
            ELSE
                (* Between 30% and 70% - maintain current state *)
                SprinklersOn := SprinklersOn;
                DelayActive := FALSE;
            END_IF;
        END_IF;
    ELSE
        (* Timer has elapsed - reset delay flag *)
        DelayActive := FALSE;
        DelayTimer(IN := FALSE, PT := ResponseDelay);
    END_IF;

END_FUNCTION_BLOCK;