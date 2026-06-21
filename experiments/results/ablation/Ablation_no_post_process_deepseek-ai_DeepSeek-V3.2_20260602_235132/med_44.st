(*
FUNCTION_BLOCK: DroneChargingStation
DESCRIPTION: Manages charging and deployment for three drones based on battery levels.
INPUTS:
    Drone1BatteryLevel, Drone2BatteryLevel, Drone3BatteryLevel: INT (0-100%)
    ChargingTime: TIME - Duration for a full charge cycle.
OUTPUTS:
    Drone1Status, Drone2Status, Drone3Status: BOOL - Active charging status.
    ChargingStationStatus: BOOL - Station busy indicator.
    DroneDeployed: BOOL - Global deployment status.
INTERNALS:
    Uses a TON timer for precise charging duration.
    Implements priority-based charging (Drone1 > Drone2 > Drone3) when battery < 20%.
    Recalls deployment (sets DroneDeployed FALSE) if any drone battery falls below 10%.
    Auto-deploys a drone (sets DroneDeployed TRUE) if battery >= 80% and station is idle.
*)

FUNCTION_BLOCK DroneChargingStation
VAR_INPUT
    Drone1BatteryLevel : INT := 0; (* Battery level of Drone 1 (0-100%) *)
    Drone2BatteryLevel : INT := 0; (* Battery level of Drone 2 (0-100%) *)
    Drone3BatteryLevel : INT := 0; (* Battery level of Drone 3 (0-100%) *)
    ChargingTime : TIME := T#30s; (* Required charging duration per drone *)
END_VAR
VAR_OUTPUT
    Drone1Status : BOOL := FALSE; (* TRUE if Drone 1 is currently charging *)
    Drone2Status : BOOL := FALSE; (* TRUE if Drone 2 is currently charging *)
    Drone3Status : BOOL := FALSE; (* TRUE if Drone 3 is currently charging *)
    ChargingStationStatus : BOOL := FALSE; (* TRUE if station is busy charging *)
    DroneDeployed : BOOL := FALSE; (* TRUE if a drone is currently deployed *)
END_VAR
VAR
    ChargingTimer : TON; (* Standard On-Delay Timer for charging *)
    CurrentDrone : INT := 0; (* 0=None, 1=Drone1, 2=Drone2, 3=Drone3 *)
    State : INT := 0; (* 0=Idle, 1=Charging Drone1, 2=Charging Drone2, 3=Charging Drone3 *)
    PrevState : INT := 0;
END_VAR

(* Main State Machine Logic *)
PrevState := State;

CASE State OF
    0: (* IDLE - Station Available *)
        (* Reset charging outputs *)
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        ChargingStationStatus := FALSE;
        CurrentDrone := 0;
        ChargingTimer(IN:=FALSE); (* Ensure timer is reset *)

        (* Priority check for drones needing charge (Battery < 20%) *)
        (* Charging only starts if no drone is currently deployed *)
        IF NOT DroneDeployed THEN
            IF Drone1BatteryLevel < 20 THEN
                State := 1;
                CurrentDrone := 1;
            ELSIF Drone2BatteryLevel < 20 THEN
                State := 2;
                CurrentDrone := 2;
            ELSIF Drone3BatteryLevel < 20 THEN
                State := 3;
                CurrentDrone := 3;
            END_IF;
        END_IF;

    1: (* CHARGING DRONE 1 *)
        (* Set outputs for Drone 1 *)
        Drone1Status := TRUE;
        ChargingStationStatus := TRUE;

        (* Start the charging timer if just entered this state *)
        IF PrevState <> State THEN
            ChargingTimer(IN:=TRUE, PT:=ChargingTime);
        END_IF;

        (* Check for deployment recall condition (any battery < 10%) *)
        IF (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10) THEN
            DroneDeployed := FALSE;
        END_IF;

        (* Check if charging is complete *)
        ChargingTimer(IN:=TRUE, PT:=ChargingTime);
        IF ChargingTimer.Q THEN
            ChargingTimer(IN:=FALSE);
            State := 0; (* Return to IDLE *)
        END_IF;

    2: (* CHARGING DRONE 2 *)
        (* Set outputs for Drone 2 *)
        Drone2Status := TRUE;
        ChargingStationStatus := TRUE;

        (* Start the charging timer if just entered this state *)
        IF PrevState <> State THEN
            ChargingTimer(IN:=TRUE, PT:=ChargingTime);
        END_IF;

        (* Check for deployment recall condition (any battery < 10%) *)
        IF (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10) THEN
            DroneDeployed := FALSE;
        END_IF;

        (* Check if charging is complete *)
        ChargingTimer(IN:=TRUE, PT:=ChargingTime);
        IF ChargingTimer.Q THEN
            ChargingTimer(IN:=FALSE);
            State := 0; (* Return to IDLE *)
        END_IF;

    3: (* CHARGING DRONE 3 *)
        (* Set outputs for Drone 3 *)
        Drone3Status := TRUE;
        ChargingStationStatus := TRUE;

        (* Start the charging timer if just entered this state *)
        IF PrevState <> State THEN
            ChargingTimer(IN:=TRUE, PT:=ChargingTime);
        END_IF;

        (* Check for deployment recall condition (any battery < 10%) *)
        IF (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10) THEN
            DroneDeployed := FALSE;
        END_IF;

        (* Check if charging is complete *)
        ChargingTimer(IN:=TRUE, PT:=ChargingTime);
        IF ChargingTimer.Q THEN
            ChargingTimer(IN:=FALSE);
            State := 0; (* Return to IDLE *)
        END_IF;
END_CASE;

(* Auto-Deployment Logic *)
(* A drone can be auto-deployed if the station is idle, no drone is currently deployed, and its battery is sufficient (>= 80%). *)
(* This logic is evaluated independently of the charging state machine. *)
IF (State = 0) AND (NOT DroneDeployed) THEN
    IF (Drone1BatteryLevel >= 80) AND (CurrentDrone <> 1) THEN
        DroneDeployed := TRUE;
    ELSIF (Drone2BatteryLevel >= 80) AND (CurrentDrone <> 2) THEN
        DroneDeployed := TRUE;
    ELSIF (Drone3BatteryLevel >= 80) AND (CurrentDrone <> 3) THEN
        DroneDeployed := TRUE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK