START_ST
FUNCTION_BLOCK HomeBrewingSystem
VAR_INPUT
    TemperatureSensor : REAL; (* Input for temperature measurement (°C) *)
    WaterFlowSensor : REAL; (* Input for water flow measurement (L/min) *)
    BrewingStartTime : TIME; (* Input for brewing process start time *)
    BrewingDuration : TIME; (* Input for total brewing duration *)
    TransferCompleteSignal : BOOL; (* Input to confirm transfer completion *)
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL; (* Output to control heating element *)
    AgitationMotor : BOOL; (* Output to control agitation motor *)
    HopsDispenser : BOOL; (* Output to control hops dispenser *)
    FermentationTank : BOOL; (* Output to control fermentation tank *)
END_VAR
VAR
    CurrentSystemTime : TOD; (* Current PLC system time *)
    ElapsedTime : TIME; (* Calculated time since start *)
    BrewingActive : BOOL; (* Flag indicating if brewing cycle is active *)
    HopsDispensed : BOOL; (* One-shot flag to ensure hops dispense only once *)
    LastState : INT; (* Tracks previous state for transition logic *)
    TARGET_TEMP : REAL := 65.0; (* Target temperature constant *)
    FLOW_THRESHOLD : REAL := 0.5; (* Flow threshold constant *)
    HOPS_TIME : TIME := 5H; (* Time for hops dispensing *)
    TRANSFER_TIME : TIME := 48H; (* Time for fermentation transfer *)
    State : INT; (* Current FSM State: 0=IDLE, 1=BREWING, 2=TRANSFER, 3=COMPLETE *)
END_VAR

(* --- Initialization and Time Calculation --- *)
(* Get current system time. If TOD is not available, use a software timer approach, 
   but assuming standard PLC with TOD for TIME arithmetic as per plan clarification. *)
CurrentSystemTime := TOD();

(* Calculate Elapsed Time if BrewingStartTime is valid and in the past/future relative to now *)
IF BrewingStartTime > T#0s THEN
    ElapsedTime := CurrentSystemTime - TOD(BrewingStartTime);
    (* Handle negative elapsed time if start time is in the future or clock reset *)
    IF ElapsedTime < T#0s THEN
        ElapsedTime := T#0s;
    END_IF;
ELSE
    ElapsedTime := T#0s;
END_IF;

(* Determine if the brewing cycle has officially started based on inputs *)
(* Transition to Active if Start Time has passed and Duration is set *)
BrewingActive := (ElapsedTime >= T#0s) AND (BrewingDuration > T#0s);

(* --- Finite State Machine Logic --- *)
(* State Definitions: 0=IDLE, 1=BREWING_ACTIVE, 2=FERMENTATION_TRANSFER, 3=COMPLETE *)

CASE State OF
    0: (* STATE 0: IDLE / INITIALIZATION *)
        (* Logic: Reset logic, wait for start condition *)
        BrewingActive := FALSE;
        HeatingElement := FALSE;
        AgitationMotor := FALSE;
        HopsDispenser := FALSE;
        FermentationTank := FALSE;
        
        (* Transition to State 1 if start time is valid and time has passed *)
        IF (BrewingStartTime > T#0s) AND (ElapsedTime >= T#0s) AND (BrewingDuration > T#0s) THEN
            State := 1;
        END_IF;

    1: (* STATE 1: BREWING ACTIVE *)
        (* Logic: Monitor Temp, Flow, Time-based events *)
        
        (* Temperature Control *)
        IF TemperatureSensor < TARGET_TEMP THEN
            HeatingElement := TRUE;
        ELSE
            HeatingElement := FALSE;
        END_IF;

        (* Agitation Control *)
        IF WaterFlowSensor > FLOW_THRESHOLD THEN
            AgitationMotor := TRUE;
        ELSE
            AgitationMotor := FALSE;
        END_IF;

        (* Hops Dispensing Logic *)
        (* Condition: ElapsedTime >= 5h AND not yet dispensed *)
        IF ElapsedTime >= HOPS_TIME AND NOT HopsDispensed THEN
            HopsDispenser := TRUE;
            HopsDispensed := TRUE; (* Set flag to prevent re-triggering *)
        ELSE
            HopsDispenser := FALSE;
        END_IF;

        (* Fermentation Transfer Logic *)
        (* Condition: ElapsedTime >= 48h AND Duration allows it (Duration >= 48h) *)
        IF ElapsedTime >= TRANSFER_TIME AND BrewingDuration >= TRANSFER_TIME THEN
            State := 2; (* Transition to Transfer State *)
        END_IF;

        (* Safety Transition: If Duration is shorter than 48h, go to Complete when duration ends *)
        IF ElapsedTime >= BrewingDuration AND BrewingDuration < TRANSFER_TIME THEN
            State := 3;
        END_IF;

        (* Default outputs for this state *)
        FermentationTank := FALSE;

    2: (* STATE 2: FERMENTATION TRANSFER *)
        (* Logic: Initiate transfer, wait for completion signal *)
        HeatingElement := FALSE;
        AgitationMotor := FALSE;
        HopsDispenser := FALSE;
        FermentationTank := TRUE; (* Activate Transfer *)

        (* Transition to Complete if transfer is acknowledged *)
        IF TransferCompleteSignal = TRUE THEN
            State := 3;
        END_IF;

    3: (* STATE 3: COMPLETE / STOPPED *)
        (* Logic: All outputs OFF *)
        HeatingElement := FALSE;
        AgitationMotor := FALSE;
        HopsDispenser := FALSE;
        FermentationTank := FALSE;
        BrewingActive := FALSE;
        
        (* Optional: Reset HopsDispensed flag if system is restarted manually, 
           though typically a new BrewingStartTime would be required to restart *)
        HopsDispensed := FALSE;
END_CASE

(* --- State Persistence Logic --- *)
(* Ensure state changes only happen on the logic cycle, preventing oscillation *)
(* The CASE statement above handles the logic. We store the result in 'State' variable.
   In a real application, one might use a separate 'NewState' variable and update 'State'
   at the end of the scan to ensure deterministic behavior, but for this single FB,
   direct assignment within the CASE block is acceptable as the outputs are derived
   from the current state evaluation. *)

END_FUNCTION_BLOCK
END_ST