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
    TimeRemaining : TIME := T#0s; (* Remaining charging time for the current charging operation *)
    CurrentChargingDrone : INT := 0; (* 0 = none, 1 = Drone1, 2 = Drone2, 3 = Drone3 *)
    InternalDeployed : BOOL := FALSE; (* Internal deployment status *)
END_VAR

(* Check if any deployed drone has critically low battery *)
IF InternalDeployed THEN
    IF (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10) THEN
        InternalDeployed := FALSE;
    END_IF;
END_IF;
DroneDeployed := InternalDeployed;

(* Charging station logic *)
IF NOT ChargingStationStatus THEN
    (* Station is free - check for drones needing charge *)
    IF (Drone1BatteryLevel < 20) AND (CurrentChargingDrone = 0) THEN
        Drone1Status := TRUE;
        ChargingStationStatus := TRUE;
        CurrentChargingDrone := 1;
        TimeRemaining := ChargingTime;
    ELSIF (Drone2BatteryLevel < 20) AND (CurrentChargingDrone = 0) THEN
        Drone2Status := TRUE;
        ChargingStationStatus := TRUE;
        CurrentChargingDrone := 2;
        TimeRemaining := ChargingTime;
    ELSIF (Drone3BatteryLevel < 20) AND (CurrentChargingDrone = 0) THEN
        Drone3Status := TRUE;
        ChargingStationStatus := TRUE;
        CurrentChargingDrone := 3;
        TimeRemaining := ChargingTime;
    END_IF;
ELSE
    (* Station is busy - manage charging timer *)
    IF TimeRemaining > T#0s THEN
        TimeRemaining := TimeRemaining - T#1ms;
    ELSE
        (* Charging complete *)
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        ChargingStationStatus := FALSE;
        CurrentChargingDrone := 0;
    END_IF;
END_IF;

(* Deployment logic - can only deploy if station is not charging *)
IF NOT ChargingStationStatus AND NOT InternalDeployed THEN
    (* Check if any drone has sufficient battery for deployment *)
    IF (Drone1BatteryLevel >= 80) OR (Drone2BatteryLevel >= 80) OR (Drone3BatteryLevel >= 80) THEN
        InternalDeployed := TRUE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK