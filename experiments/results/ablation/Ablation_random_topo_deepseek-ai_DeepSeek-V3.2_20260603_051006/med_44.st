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
    ChargingDrone : INT := 0; (* 0 = none, 1 = drone1, 2 = drone2, 3 = drone3 *)
    TimerActive : BOOL := FALSE; (* Timer activation flag *)
END_VAR

(* Deployment recall logic - check if any drone battery falls below 10% *)
IF DroneDeployed THEN
    IF (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10) THEN
        DroneDeployed := FALSE;
    END_IF;
END_IF;

(* Charging station management logic *)
IF NOT ChargingStationStatus THEN
    (* Station is free - check for drones needing charge *)
    Drone1Status := FALSE;
    Drone2Status := FALSE;
    Drone3Status := FALSE;
    TimerActive := FALSE;
    
    IF ChargingDrone = 0 THEN
        (* Select first drone with battery below 20% *)
        IF (Drone1BatteryLevel < 20) AND (Drone1BatteryLevel >= 0) THEN
            ChargingDrone := 1;
            TimeRemaining := ChargingTime;
        ELSIF (Drone2BatteryLevel < 20) AND (Drone2BatteryLevel >= 0) THEN
            ChargingDrone := 2;
            TimeRemaining := ChargingTime;
        ELSIF (Drone3BatteryLevel < 20) AND (Drone3BatteryLevel >= 0) THEN
            ChargingDrone := 3;
            TimeRemaining := ChargingTime;
        END_IF;
    END_IF;
    
    (* Start charging if a drone is selected *)
    IF ChargingDrone > 0 THEN
        ChargingStationStatus := TRUE;
        TimerActive := TRUE;
        
        CASE ChargingDrone OF
            1: Drone1Status := TRUE;
            2: Drone2Status := TRUE;
            3: Drone3Status := TRUE;
        END_CASE;
    END_IF;
ELSE
    (* Station is busy - handle charging timer *)
    IF TimerActive THEN
        IF TimeRemaining > T#0s THEN
            TimeRemaining := TimeRemaining - T#1ms; (* Decrement timer - adjust cycle time as needed *)
        ELSE
            (* Charging complete *)
            Drone1Status := FALSE;
            Drone2Status := FALSE;
            Drone3Status := FALSE;
            ChargingStationStatus := FALSE;
            ChargingDrone := 0;
            TimerActive := FALSE;
            TimeRemaining := T#0s;
        END_IF;
    END_IF;
END_IF;

END_FUNCTION_BLOCK