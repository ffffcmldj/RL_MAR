ructured-text
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
    TimeRemaining : TIME := ChargingTime; (* Remaining charging time for the current charging operation *)
    state : INT := 0; (* Current state of the charging station *)
END_VAR

(* Main logic *)
CASE state OF
    0: (* IDLE State *)
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        ChargingStationStatus := FALSE;
        DroneDeployed := FALSE;

        IF (Drone1BatteryLevel < 20) AND (ChargingStationStatus = FALSE) THEN
            state := 1; (* Transition to CHARGING_DRONE1 *)
        ELSIF (Drone2BatteryLevel < 20) AND (ChargingStationStatus = FALSE) THEN
            state := 2; (* Transition to CHARGING_DRONE2 *)
        ELSIF (Drone3BatteryLevel < 20) AND (ChargingStationStatus = FALSE) THEN
            state := 3; (* Transition to CHARGING_DRONE3 *)
        END_IF;

    1: (* CHARGING_DRONE1 State *)
        Drone1Status := TRUE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        ChargingStationStatus := TRUE;
        DroneDeployed := FALSE;

        TimeRemaining := TimeRemaining - T#1s; (* Decrement time remaining *)

        IF TimeRemaining <= T#0s THEN
            state := 0; (* Transition back to IDLE *)
            TimeRemaining := ChargingTime; (* Reset time remaining *)
        END_IF;

    2: (* CHARGING_DRONE2 State *)
        Drone1Status := FALSE;
        Drone2Status := TRUE;
        Drone3Status := FALSE;
        ChargingStationStatus := TRUE;
        DroneDeployed := FALSE;

        TimeRemaining := TimeRemaining - T#1s; (* Decrement time remaining *)

        IF TimeRemaining <= T#0s THEN
            state := 0; (* Transition back to IDLE *)
            TimeRemaining := ChargingTime; (* Reset time remaining *)
        END_IF;

    3: (* CHARGING_DRONE3 State *)
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := TRUE;
        ChargingStationStatus := TRUE;
        DroneDeployed := FALSE;

        TimeRemaining := TimeRemaining - T#1s; (* Decrement time remaining *)

        IF TimeRemaining <= T#0s THEN
            state := 0; (* Transition back to IDLE *)
            TimeRemaining := ChargingTime; (* Reset time remaining *)
        END_IF;

    4: (* DEPLOYED State *)
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        ChargingStationStatus := FALSE;

        IF (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10) THEN
            DroneDeployed := FALSE; (* Recall the drone *)
        END_IF;

END_CASE;

END_FUNCTION_BLOCK