START_ST
FUNCTION_BLOCK DroneChargingStation
VAR_INPUT
    Drone1BatteryLevel : INT := 0; (* Battery level of Drone 1 (0-100%) *)
    Drone2BatteryLevel : INT := 0; (* Battery level of Drone 2 (0-100%) *)
    Drone3BatteryLevel : INT := 0; (* Battery level of Drone 3 (0-100%) *)
    ChargingTime : TIME := T#30s; (* Charging time required for each drone *)
END_VAR
VAR_OUTPUT
    Drone1Status : BOOL := FALSE; (* Status of Drone 1 *)
    Drone2Status : BOOL := FALSE; (* Status of Drone 2 *)
    Drone3Status : BOOL := FALSE; (* Status of Drone 3 *)
    ChargingStationStatus : BOOL := FALSE; (* Charging station status *)
    DroneDeployed : BOOL := FALSE; (* Indicates if a drone is deployed *)
END_VAR
VAR
    CurrentState : INT; (* 0:IDLE, 1:CHARGING_D1, 2:CHARGING_D2, 3:CHARGING_D3, 4:DEPLOYED *)
    TimeRemaining : TIME := ChargingTime; (* Remaining charging time *)
    RecallTriggered : BOOL := FALSE; (* Internal flag to handle recall logic *)
END_VAR

BEGIN
    (* --- STATE MACHINE LOGIC --- *)

    (* Check for Recall Condition (State 4 Logic) *)
    (* Note: Without an external 'IsDeployed' input, we assume if the system is in State 4,
       it is monitoring a deployed drone. If battery < 10%, we force recall. *)
    (* Since we cannot add an input to enter State 4, we assume State 4 is entered
       by external logic not shown, or we treat the 'DroneDeployed' output as the trigger
       for the next cycle if it were an input. To satisfy the requirement strictly with
       given inputs, we will implement the recall logic assuming the system knows a drone
       is deployed (State 4). If no external signal enters State 4, this block defaults
       to Idle or Charging based on battery levels. *)
    
    (* To make the code functional with the provided inputs, we assume the 'DroneDeployed'
       output is set TRUE by external logic. If it is TRUE, we enter the monitoring logic.
       However, since 'DroneDeployed' is an output, we cannot use it to drive logic in the
       same scan cycle without a state variable. We will use CurrentState to track this.
       We will assume that if CurrentState is 4, the drone is deployed. *)
    
    (* Transition Logic *)
    
    (* State 0: IDLE - Check for charging needs *)
    IF CurrentState = 0 THEN
        (* Priority: Drone 1, then Drone 2, then Drone 3 *)
        IF Drone1BatteryLevel < 20 THEN
            CurrentState := 1;
        ELSEIF Drone2BatteryLevel < 20 THEN
            CurrentState := 2;
        ELSEIF Drone3BatteryLevel < 20 THEN
            CurrentState := 3;
        ELSE
            (* No drone needs charging *)
            CurrentState := 0;
        END_IF;
    END_IF;

    (* State 1: CHARGING_DRONE1 *)
    IF CurrentState = 1 THEN
        (* Decrement time *)
        IF TimeRemaining > T#0s THEN
            TimeRemaining := TimeRemaining - T#1s;
        ELSE
            (* Charging Complete *)
            TimeRemaining := ChargingTime; (* Reset for next cycle *)
            CurrentState := 0;
        END_IF;
    END_IF;

    (* State 2: CHARGING_DRONE2 *)
    IF CurrentState = 2 THEN
        IF TimeRemaining > T#0s THEN
            TimeRemaining := TimeRemaining - T#1s;
        ELSE
            TimeRemaining := ChargingTime;
            CurrentState := 0;
        END_IF;
    END_IF;

    (* State 3: CHARGING_DRONE3 *)
    IF CurrentState = 3 THEN
        IF TimeRemaining > T#0s THEN
            TimeRemaining := TimeRemaining - T#1s;
        ELSE
            TimeRemaining := ChargingTime;
            CurrentState := 0;
        END_IF;
    END_IF;

    (* State 4: DEPLOYED - Monitor for Recall *)
    (* Assumption: This state is entered if an external condition (not in inputs) sets it.
       With only the provided inputs, we cannot reliably enter State 4 unless we assume
       the user sets CurrentState = 4 externally or via a hidden mechanism.
       However, to fulfill the "Recall" requirement: If in State 4 and battery < 10, exit. *)
    IF CurrentState = 4 THEN
        IF (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10) THEN
            (* Recall Triggered *)
            CurrentState := 0;
            RecallTriggered := TRUE;
        ELSE
            (* Continue Monitoring *)
            RecallTriggered := FALSE;
        END_IF;
    END_IF;

    (* --- OUTPUT ASSIGNMENT LOGIC --- *)

    (* Assign Drone Statuses based on State *)
    CASE CurrentState OF
        0: (* IDLE *)
            Drone1Status := FALSE;
            Drone2Status := FALSE;
            Drone3Status := FALSE;
            ChargingStationStatus := FALSE;
            (* DroneDeployed is handled by external logic or state 4 logic *)
            IF RecallTriggered THEN
                DroneDeployed := FALSE;
            ELSE
                (* Default to FALSE if not in State 4, as we cannot detect deployment without input *)
                DroneDeployed := FALSE;
            END_IF;
            
        1: (* CHARGING_DRONE1 *)
            Drone1Status := TRUE;
            Drone2Status := FALSE;
            Drone3Status := FALSE;
            ChargingStationStatus := TRUE;
            DroneDeployed := FALSE;
            
        2: (* CHARGING_DRONE2 *)
            Drone1Status := FALSE;
            Drone2Status := TRUE;
            Drone3Status := FALSE;
            ChargingStationStatus := TRUE;
            DroneDeployed := FALSE;
            
        3: (* CHARGING_DRONE3 *)
            Drone1Status := FALSE;
            Drone2Status := FALSE;
            Drone3Status := TRUE;
            ChargingStationStatus := TRUE;
            DroneDeployed := FALSE;
            
        4: (* DEPLOYED *)
            Drone1Status := FALSE;
            Drone2Status := FALSE;
            Drone3Status := FALSE;
            ChargingStationStatus := FALSE;
            DroneDeployed := TRUE; (* Assume deployed if in this state *)
    END_CASE;

END_FUNCTION_BLOCK
END_ST