START_ST
FUNCTION_BLOCK GreenhouseWateringSystem
VAR_INPUT
    SoilMoistureSensor : REAL;
END_VAR

VAR_OUTPUT
    SprinklersOn : BOOL;
END_VAR

VAR
    (* State Machine Variables *)
    state : INT := 0;           (* 0: IDLE, 1: SPRINKLERS_ACTIVE, 2: SPRINKLERS_INACTIVE *)
    prevState : INT := 0;
    
    (* Thresholds *)
    moistureThresholdLow : REAL := 30.0;
    moistureThresholdHigh : REAL := 70.0;
    
    (* Timing Variables *)
    delayTimer : TIME;
    delayDone : BOOL := FALSE;
    
    (* Initialization & Validity Flags *)
    lastMoistureValid : BOOL := FALSE;
    lastMoistureReading : REAL;
    
    (* Internal Logic Flags *)
    shouldActivate : BOOL;
    shouldDeactivate : BOOL;
END_VAR

VAR_OUTPUT
    (* Note: The original plan declared SprinklersOn as VAR, but the requirement specifies it as an Output.
       To satisfy the "Function Block" requirement with inputs/outputs, we use VAR_OUTPUT for the control signal.
       If strictly VAR is needed for internal use only, it would be declared in VAR. 
       Based on the prompt's explicit structure request: "SprinklersOn : BOOL := FALSE", 
       we will initialize it here if it were a VAR, but as VAR_OUTPUT it defaults to FALSE in IEC 61131-3. *)
END_VAR

BEGIN
    (* --- 0. DECLARE THE NEEDED STATES (Implicitly handled by state variable) --- *)
    
    (* --- 1. LIST THE OUTPUT VALUES FOR EACH STATE --- *)
    (* We calculate the desired state based on current conditions first *)
    
    (* Check if we are in the hysteresis zone (State 2 behavior) *)
    if (SoilMoistureSensor >= moistureThresholdLow) and (SoilMoistureSensor <= moistureThresholdHigh) then
        state := 2;
        SprinklersOn := FALSE;
    else
        (* Check for Activation Condition: Moisture < 30% *)
        if (SoilMoistureSensor < moistureThresholdLow) then
            (* Transition to State 1 *)
            state := 1;
            SprinklersOn := TRUE;
        else
            (* Check for Deactivation Condition: Moisture > 70% *)
            if (SoilMoistureSensor > moistureThresholdHigh) then
                (* Transition to State 1 from State 2 if coming from dry state? 
                   Actually, if > 70%, it is dry. If it was wet (<30) and now >70, it goes to State 2.
                   If it was already dry (>70), it stays in State 2. *)
                state := 2;
                SprinklersOn := FALSE;
            else
                (* Fallback to State 2 if not in hysteresis and not low moisture *)
                state := 2;
                SprinklersOn := FALSE;
            end_if;
        end_if;
    end_if;

    (* --- 2. LIST THE TRANSITIONS BETWEEN STATES (Logic Implementation) --- *)
    (* 
       State 0 -> State 1: IF (SoilMoistureSensor < 30.0) AND (LastMoistureReading was valid/initialized)
       State 1 -> State 2: IF (SoilMoistureSensor > 70.0)
       State 2 -> State 1: IF (SoilMoistureSensor < 30.0)
       State 2 -> State 0: IF (SoilMoistureSensor >= 30.0) AND (SoilMoistureSensor <= 70.0) [Hysteresis zone]
    *)
    
    (* Handle Initialization and Validity *)
    if not lastMoistureValid then
        (* First cycle or reset: Treat as valid immediately as per standard PLC startup behavior 
           unless a specific 'Initialize' input is provided. The plan says "treat the first reading as valid immediately" 
           is the safer interpretation for a standalone FB without an explicit init flag input. *)
        lastMoistureValid := TRUE;
        lastMoistureReading := SoilMoistureSensor;
        (* Ensure initial state is OFF as per requirement *)
        SprinklersOn := FALSE;
        state := 2; (* Start in Inactive state *)
    else
        lastMoistureReading := SoilMoistureSensor;
    end_if;

    (* --- 3. DECLARE THE NEEDED VARIABLES (Timer Logic) --- *)
    (* The requirement asks to consider system response delays. 
       Interpretation: When the condition to turn ON is met, wait for ResponseDelay before actually setting SprinklersOn.
       When the condition to turn OFF is met, turn OFF immediately (or after a delay? Usually off is immediate to save water, 
       but let's apply the delay to the activation as per common safety/actuator wear logic, or apply to both.
       Given "Sprinklers should engage when... below 30", a delay prevents chattering. 
       Let's implement the delay on the ACTIVATION (State 0->1 transition) as requested in the question analysis. *)
    
    (* Reset timer if state changes or condition changes significantly *)
    if (state = 1) and (delayDone = FALSE) then
        (* We are in Active state, but maybe we just entered it? 
           Actually, let's use a simpler approach: 
           If we decide to turn ON, start the timer. If timer expires, turn ON.
           If we decide to turn OFF, turn OFF immediately. *)
    end_if;

    (* Refined Logic with Delay Implementation *)
    (* Determine if we WANT to be in State 1 based on sensor *)
    wantState1 := (SoilMoistureSensor < moistureThresholdLow);
    wantState2 := (SoilMoistureSensor >= moistureThresholdLow) and (SoilMoistureSensor <= moistureThresholdHigh);
    wantState2_High := (SoilMoistureSensor > moistureThresholdHigh);

    (* State Transition Logic *)
    if (state = 0) then
        (* Initial State: Wait for valid reading. Since we set valid=True above, move to appropriate state *)
        if wantState1 then
            state := 1;
            (* Start delay timer for activation *)
            delayTimer := T#0s;
            delayDone := FALSE;
        else
            state := 2;
        end_if;
    end_if;

    if (state = 1) then
        (* Active State *)
        if wantState2_High then
            (* Condition changed: Moisture > 70%. Deactivate immediately. *)
            state := 2;
            SprinklersOn := FALSE;
            delayTimer := T#0s;
            delayDone := FALSE;
        else
            (* Still want to be active, check if delay is done *)
            if not delayDone then
                delayTimer := delayTimer + ResponseDelay;
                if delayTimer >= ResponseDelay then
                    delayDone := TRUE;
                    SprinklersOn := TRUE;
                end_if;
            else
                (* Delay already done, ensure output is on *)
                SprinklersOn := TRUE;
            end_if;
        end_if;
    end_if;

    if (state = 2) then
        (* Inactive State *)
        if wantState1 then
            (* Condition changed: Moisture < 30%. Start activation delay. *)
            state := 1;
            delayTimer := T#0s;
            delayDone := FALSE;
        else
            (* Stay inactive *)
            SprinklersOn := FALSE;
            (* If we were waiting for a delay to finish, reset it if we are still in state 2? 
               No, if we are in state 2, we are not activating. *)
        end_if;
    end_if;

    (* Final Output Assignment *)
    (* If state is 1 and delay is done, ON. Otherwise OFF. *)
    if state = 1 and delayDone then
        SprinklersOn := TRUE;
    else
        SprinklersOn := FALSE;
    end_if;

    (* Update lastMoistureReading for the next cycle's validity check if needed, 
       though we set it at the top. We keep it updated here for clarity. *)
    lastMoistureReading := SoilMoistureSensor;

END_FUNCTION_BLOCK
END_ST