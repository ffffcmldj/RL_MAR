pascal
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
    state : INT := 0; (* Current state of the system *)
    prevState : INT := 0; (* Previous state of the system *)
    TimeRemaining : TIME := T#0s; (* Remaining charging time for the current operation *)
END_VAR

(* Finite State Machine Logic *)
CASE state OF
    0: (* STATE 0: IDLE *)
        (* Reset all statuses *)
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        ChargingStationStatus := FALSE;

        (* Check for drones needing charging *)
        IF Drone1BatteryLevel < 20 AND NOT ChargingStationStatus THEN
            state := 1; (* Transition to STATE 1: CHARGING_DRONE1 *)
            TimeRemaining := ChargingTime;
        ELSIF Drone2BatteryLevel < 20 AND NOT ChargingStationStatus THEN
            state := 2; (* Transition to STATE 2: CHARGING_DRONE2 *)
            TimeRemaining := ChargingTime;
        ELSIF Drone3BatteryLevel < 20 AND NOT ChargingStationStatus THEN
            state := 3; (* Transition to STATE 3: CHARGING_DRONE3 *)
            TimeRemaining := ChargingTime;
        END_IF;

        (* Check if a drone is deployed and battery levels are sufficient *)
        IF DroneDeployed THEN
            IF Drone1BatteryLevel < 10 OR Drone2BatteryLevel < 10 OR Drone3BatteryLevel < 10 THEN
                DroneDeployed := FALSE; (* Recall the drone *)
            END_IF;
        END_IF;

    1: (* STATE 1: CHARGING_DRONE1 *)
        Drone1Status := TRUE;
        ChargingStationStatus := TRUE;

        (* Decrement charging time *)
        IF TimeRemaining > T#0s THEN
            TimeRemaining := TimeRemaining - T#1s; (* Assuming 1-second cycle time *)
        ELSE
            (* Charging complete, reset statuses and transition to IDLE *)
            Drone1Status := FALSE;
            ChargingStationStatus := FALSE;
            state := 0; (* Transition to STATE 0: IDLE *)
        END_IF;

    2: (* STATE 2: CHARGING_DRONE2 *)
        Drone2Status := TRUE;
        ChargingStationStatus := TRUE;

        (* Decrement charging time *)
        IF TimeRemaining > T#0s THEN
            TimeRemaining := TimeRemaining - T#1s; (* Assuming 1-second cycle time *)
        ELSE
            (* Charging complete, reset statuses and transition to IDLE *)
            Drone2Status := FALSE;
            ChargingStationStatus := FALSE;
            state := 0; (* Transition to STATE 0: IDLE *)
        END_IF;

    3: (* STATE 3: CHARGING_DRONE3 *)
        Drone3Status := TRUE;
        ChargingStationStatus := TRUE;

        (* Decrement charging time *)
        IF TimeRemaining > T#0s THEN
            TimeRemaining := TimeRemaining - T#1s; (* Assuming 1-second cycle time *)
        ELSE
            (* Charging complete, reset statuses and transition to IDLE *)
            Drone3Status := FALSE;
            ChargingStationStatus := FALSE;
            state := 0; (* Transition to STATE 0: IDLE *)
        END_IF;

    4: (* STATE 4: DEPLOYED *)
        DroneDeployed := TRUE;

        (* Monitor battery levels *)
        IF Drone1BatteryLevel < 10 OR Drone2BatteryLevel < 10 OR Drone3BatteryLevel < 10 THEN
            DroneDeployed := FALSE; (* Recall the drone *)
            state := 0; (* Transition to STATE 0: IDLE *)
        END_IF;

    ELSE
        (* Default case: Reset to IDLE *)
        state := 0;
END_CASE;
END_FUNCTION_BLOCK
END_ST