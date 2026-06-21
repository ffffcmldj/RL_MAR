(*
FUNCTION_BLOCK: DroneChargingStation
DESCRIPTION: Manages charging and deployment for three drones based on battery levels.
LOGIC: Implements a state machine with three states (Idle, Charging, Deployed).
       - Idle: Checks for drones with battery < 20% and starts charging the first one found.
                If no drones need charging and all batteries >= 20%, allows deployment.
       - Charging: Charges a specific drone for the configured ChargingTime.
       - Deployed: Monitors battery levels and recalls (returns to Idle) if any battery falls below 10%.
*)

FUNCTION_BLOCK DroneChargingStation
VAR_INPUT
    Drone1BatteryLevel : INT := 0; (* Battery level of Drone 1 (0-100%) *)
    Drone2BatteryLevel : INT := 0; (* Battery level of Drone 2 (0-100%) *)
    Drone3BatteryLevel : INT := 0; (* Battery level of Drone 3 (0-100%) *)
    ChargingTime : TIME := T#30s;  (* Required charging duration *)
END_VAR
VAR_OUTPUT
    Drone1Status : BOOL := FALSE;        (* TRUE if Drone 1 is charging *)
    Drone2Status : BOOL := FALSE;        (* TRUE if Drone 2 is charging *)
    Drone3Status : BOOL := FALSE;        (* TRUE if Drone 3 is charging *)
    ChargingStationStatus : BOOL := FALSE; (* TRUE if station is charging a drone *)
    DroneDeployed : BOOL := FALSE;       (* TRUE if a drone is deployed *)
END_VAR
VAR
    (* State Management *)
    CurrentState : INT := 0; (* 0: Idle, 1: Charging, 2: Deployed *)
    ChargingDrone : INT := 0; (* 0: None, 1: Drone1, 2: Drone2, 3: Drone3 *)
    TimeRemaining : TIME;
END_VAR

(* Main State Machine *)
CASE CurrentState OF
    0: (* IDLE STATE *)
        (* Reset charging outputs *)
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        ChargingStationStatus := FALSE;
        DroneDeployed := FALSE;
        ChargingDrone := 0;
        
        (* Check for drones needing charge (priority: Drone1 > Drone2 > Drone3) *)
        IF Drone1BatteryLevel < 20 THEN
            ChargingDrone := 1;
            TimeRemaining := ChargingTime;
            CurrentState := 1;
        ELSIF Drone2BatteryLevel < 20 THEN
            ChargingDrone := 2;
            TimeRemaining := ChargingTime;
            CurrentState := 1;
        ELSIF Drone3BatteryLevel < 20 THEN
            ChargingDrone := 3;
            TimeRemaining := ChargingTime;
            CurrentState := 1;
        ELSE
            (* No drones need charging. Check if deployment is possible. *)
            (* Deployment allowed only if all batteries are at least 20% *)
            IF (Drone1BatteryLevel >= 20) AND (Drone2BatteryLevel >= 20) AND (Drone3BatteryLevel >= 20) THEN
                CurrentState := 2;
            ELSE
                CurrentState := 0;
            END_IF;
        END_IF;
        
    1: (* CHARGING STATE *)
        (* Set station status and the specific drone's charging status *)
        ChargingStationStatus := TRUE;
        CASE ChargingDrone OF
            1: Drone1Status := TRUE;
            2: Drone2Status := TRUE;
            3: Drone3Status := TRUE;
        END_CASE;
        
        (* Decrement the charging timer *)
        TimeRemaining := TimeRemaining - T#1ms;
        
        (* Check if charging is complete *)
        IF TimeRemaining <= T#0ms THEN
            (* Charging complete, return to Idle state *)
            CurrentState := 0;
        ELSE
            CurrentState := 1;
        END_IF;
        
    2: (* DEPLOYED STATE *)
        (* A drone is deployed. Station is not in use for charging. *)
        DroneDeployed := TRUE;
        ChargingStationStatus := FALSE;
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        
        (* Recall condition: If ANY drone's battery falls below 10%, return to Idle *)
        IF (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10) THEN
            DroneDeployed := FALSE;
            CurrentState := 0;
        ELSE
            CurrentState := 2;
        END_IF;
        
END_CASE;

END_FUNCTION_BLOCK