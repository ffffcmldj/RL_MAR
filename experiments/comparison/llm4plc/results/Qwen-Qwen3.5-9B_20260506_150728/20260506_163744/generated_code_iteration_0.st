START_ST
FUNCTION_BLOCK HomeBrewingSystem
VAR_INPUT
    TemperatureSensor : REAL; (* Input for temperature measurement *)
    WaterFlowSensor : REAL; (* Input for water flow measurement *)
    BrewingStartTime : TIME; (* Input for brewing start time *)
    BrewingDuration : TIME; (* Input for brewing duration *)
    CurrentTime : TIME; (* Input for current system time to calculate elapsed duration *)
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL; (* Output for heating element *)
    AgitationMotor : BOOL; (* Output for agitation motor *)
    HopsDispenser : BOOL; (* Output for hops dispenser *)
    FermentationTank : BOOL; (* Output for fermentation tank *)
END_VAR
VAR
    CurrentState : INT; (* FSM State Variable (0 to 3) *)
    TimeElapsed : TIME; (* Calculated variable: CurrentTime - BrewingStartTime *)
    HopsTimerTriggered : BOOL; (* Internal flag to ensure Hops dispenser stays ON once triggered *)
    FermentationTimerTriggered : BOOL; (* Internal flag to ensure Fermentation tank stays ON once triggered *)
END_VAR

(* --- STATE 0: IDLE / INITIALIZATION --- *)
(* Logic: System waits or runs continuous logic based on inputs.
   If TimeElapsed is 0 or less, we are effectively in the initial state.
   Outputs are determined by sensor readings only. *)
IF CurrentState = 0 THEN
    (* Calculate elapsed time safely *)
    TimeElapsed := CurrentTime - BrewingStartTime;
    
    (* Sensor Logic *)
    HeatingElement := (TemperatureSensor < 65.0);
    AgitationMotor := (WaterFlowSensor > 0.5);
    
    (* Time-based Logic: Not triggered yet *)
    HopsDispenser := FALSE;
    FermentationTank := FALSE;

    (* Transition to State 1 immediately if time has started or if we assume start condition is met *)
    (* Per plan: STATE 0 -> STATE 1 is immediate entry upon execution if brewing has logically started *)
    (* We assume if BrewingStartTime is valid and CurrentTime is valid, we enter brewing phase *)
    IF TimeElapsed >= T#0H THEN
        CurrentState := 1;
    END_IF;
END_IF;

(* --- STATE 1: BREWING PHASE 1 --- *)
(* Logic: Heating and Agitation active (based on sensors), Hops and Fermentation inactive.
   Transition to State 2 when TimeElapsed >= 5.0 Hours *)
IF CurrentState = 1 THEN
    (* Sensor Logic *)
    HeatingElement := (TemperatureSensor < 65.0);
    AgitationMotor := (WaterFlowSensor > 0.5);
    
    (* Time-based Logic: Not triggered yet *)
    HopsDispenser := FALSE;
    FermentationTank := FALSE;

    (* Transition Logic: STATE 1 -> STATE 2 *)
    IF TimeElapsed >= T#5H THEN
        CurrentState := 2;
    END_IF;
END_IF;

(* --- STATE 2: BREWING PHASE 2 --- *)
(* Logic: Hops Dispensing active, Fermentation inactive.
   Transition to State 3 when TimeElapsed >= 48.0 Hours *)
IF CurrentState = 2 THEN
    (* Sensor Logic *)
    HeatingElement := (TemperatureSensor < 65.0);
    AgitationMotor := (WaterFlowSensor > 0.5);
    
    (* Time-based Logic: Triggered *)
    HopsDispenser := TRUE;
    FermentationTank := FALSE;

    (* Transition Logic: STATE 2 -> STATE 3 *)
    IF TimeElapsed >= T#48H THEN
        CurrentState := 3;
    END_IF;
END_IF;

(* --- STATE 3: BREWING PHASE 3 --- *)
(* Logic: Fermentation active.
   Transition to State 1 (Reset/End of Cycle) when TimeElapsed > BrewingDuration *)
IF CurrentState = 3 THEN
    (* Sensor Logic *)
    HeatingElement := (TemperatureSensor < 65.0);
    AgitationMotor := (WaterFlowSensor > 0.5);
    
    (* Time-based Logic: Triggered *)
    HopsDispenser := TRUE;
    FermentationTank := TRUE;

    (* Transition Logic: STATE 3 -> STATE 1 (End of Cycle) *)
    (* Requirement: Stop all components when TimeElapsed >= BrewingDuration *)
    IF TimeElapsed >= BrewingDuration THEN
        (* Reset State to 0 to stop all outputs and wait for new start signal *)
        CurrentState := 0;
    END_IF;
END_IF;

END_FUNCTION_BLOCK
END_ST