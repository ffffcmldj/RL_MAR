ructured-text
START_ST
FUNCTION_BLOCK GreenhouseWateringSystem
    VAR
        state : INT;                     (* Current state of the system *)
        prevState : INT;                (* Previous state of the system *)
        SoilMoistureSensor : REAL;      (* Input for soil moisture level (0-100%) *)
        SprinklersOn : BOOL := FALSE;    (* Output for controlling sprinklers - on/off *)
        ResponseDelay : TIME := T#5s;   (* Example response delay for the system *)
        LastMoistureReading : REAL;      (* Last recorded soil moisture reading *)
        DelayTimer : TON;                (* Timer for response delay *)
    END_VAR

    (* State Definitions *)
    CONSTANT STATE_INITIALIZE : INT := 0;
    CONSTANT STATE_WAIT : INT := 1;
    CONSTANT STATE_SPRINKLERS_ON : INT := 2;
    CONSTANT STATE_SPRINKLERS_OFF : INT := 3;

    (* Initialization *)
    IF state = STATE_INITIALIZE THEN
        SprinklersOn := FALSE;
        state := STATE_WAIT;  (* Transition to WAIT state after initialization *)
    END_IF

    (* State Machine Logic *)
    CASE state OF
        STATE_WAIT:
            (* Wait for soil moisture reading *)
            LastMoistureReading := SoilMoistureSensor;  (* Update last moisture reading *)
            IF SoilMoistureSensor < 30.0 THEN
                state := STATE_SPRINKLERS_ON;  (* Activate sprinklers if moisture is low *)
            ELSIF SoilMoistureSensor > 70.0 THEN
                state := STATE_SPRINKLERS_OFF;  (* Deactivate sprinklers if moisture is high *)
            END_IF

        STATE_SPRINKLERS_ON:
            SprinklersOn := TRUE;  (* Turn on sprinklers *)
            IF SoilMoistureSensor >= 30.0 THEN
                state := STATE_WAIT;  (* Check moisture level again *)
            END_IF

        STATE_SPRINKLERS_OFF:
            SprinklersOn := FALSE;  (* Turn off sprinklers *)
            IF SoilMoistureSensor <= 70.0 THEN
                state := STATE_WAIT;  (* Check moisture level again *)
            END_IF

    END_CASE

END_FUNCTION_BLOCK
END_ST