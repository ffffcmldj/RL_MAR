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
    ChargingActive : BOOL := FALSE; (* Internal flag for charging operation *)
    ChargingDrone : INT := 0; (* 0=none, 1=drone1, 2=drone2, 3=drone3 *)
END_VAR

(* Main charging logic *)
IF NOT ChargingActive THEN
    (* Charging station is not in use, check for low battery drones *)
    Drone1Status := FALSE;
    Drone2Status := FALSE;
    Drone3Status := FALSE;
    ChargingStationStatus := FALSE;
    ChargingDrone := 0;
    
    (* Check drones in order for battery below 20% *)
    IF Drone1BatteryLevel < 20 THEN
        Drone1Status := TRUE;
        ChargingActive := TRUE;
        ChargingStationStatus := TRUE;
        TimeRemaining := ChargingTime;
        ChargingDrone := 1;
    ELSIF Drone2BatteryLevel < 20 THEN
        Drone2Status := TRUE;
        ChargingActive := TRUE;
        ChargingStationStatus := TRUE;
        TimeRemaining := ChargingTime;
        ChargingDrone := 2;
    ELSIF Drone3BatteryLevel < 20 THEN
        Drone3Status := TRUE;
        ChargingActive := TRUE;
        ChargingStationStatus := TRUE;
        TimeRemaining := ChargingTime;
        ChargingDrone := 3;
    END_IF;
ELSE
    (* Charging station is in use *)
    ChargingStationStatus := TRUE;
    
    (* Decrement charging timer *)
    IF TimeRemaining > T#0s THEN
        TimeRemaining := TimeRemaining - T#1ms; (* Decrement by 1 millisecond *)
    END_IF;
    
    (* Check if charging is complete *)
    IF TimeRemaining <= T#0s THEN
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        ChargingStationStatus := FALSE;
        ChargingActive := FALSE;
        ChargingDrone := 0;
        TimeRemaining := T#0s;
    END_IF;
END_IF;

(* Deployment logic based on battery levels *)
IF DroneDeployed THEN
    (* If a drone is deployed, check if any drone battery is critically low *)
    IF (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10) THEN
        DroneDeployed := FALSE; (* Recall the drone *)
    END_IF;
END_IF;

(* Note: DroneDeployed is set to TRUE by external logic when a drone is deployed *)

END_FUNCTION_BLOCK