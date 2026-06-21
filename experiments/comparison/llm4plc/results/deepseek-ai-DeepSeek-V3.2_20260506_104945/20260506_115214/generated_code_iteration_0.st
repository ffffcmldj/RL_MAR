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
    TimeRemaining : TIME := T#0s; (* Remaining charging time for the current charging operation *)
    state : INT := 0; (* Current state of the FSM (0: IDLE, 1: CHARGING_DRONE1, 2: CHARGING_DRONE2, 3: CHARGING_DRONE3, 4: DEPLOYED) *)
    prevState : INT := 0; (* Previous state for edge detection *)
    recallTriggered : BOOL := FALSE; (* Internal flag to handle recall condition *)
    chargingDrone : INT := 0; (* Tracks which drone is currently charging (1,2,3) *)
END_VAR

(* State Machine Execution *)
CASE state OF
    0: (* IDLE *)
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        ChargingStationStatus := FALSE;
        DroneDeployed := FALSE;
        
        (* Check for recall condition from any state - if deployed and any battery < 10%, force recall to IDLE *)
        IF recallTriggered THEN
            recallTriggered := FALSE;
            state := 0;
        ELSIF (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10) THEN
            (* Battery low but not deployed, stay in IDLE *)
            state := 0;
        ELSIF (Drone1BatteryLevel < 20) AND (NOT DroneDeployed) THEN
            state := 1; (* CHARGING_DRONE1 *)
            TimeRemaining := ChargingTime;
            chargingDrone := 1;
        ELSIF (Drone2BatteryLevel < 20) AND (NOT DroneDeployed) THEN
            state := 2; (* CHARGING_DRONE2 *)
            TimeRemaining := ChargingTime;
            chargingDrone := 2;
        ELSIF (Drone3BatteryLevel < 20) AND (NOT DroneDeployed) THEN
            state := 3; (* CHARGING_DRONE3 *)
            TimeRemaining := ChargingTime;
            chargingDrone := 3;
        ELSE
            (* No charging needed, check for deployment trigger *)
            (* Deployment trigger is external via DroneDeployed input *)
            IF DroneDeployed THEN
                state := 4; (* DEPLOYED *)
            END_IF;
        END_IF;
        
    1: (* CHARGING_DRONE1 *)
        Drone1Status := TRUE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        ChargingStationStatus := TRUE;
        DroneDeployed := FALSE;
        
        (* Check recall condition *)
        IF (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10) THEN
            recallTriggered := TRUE;
            state := 0;
        ELSIF TimeRemaining <= T#0s THEN
            state := 0; (* Charging complete *)
        ELSIF DroneDeployed THEN
            state := 4; (* Deployment requested while charging *)
        ELSE
            (* Continue charging *)
            TimeRemaining := TimeRemaining - T#1ms; (* Decrement time - adjust cycle time as needed *)
        END_IF;
        
    2: (* CHARGING_DRONE2 *)
        Drone1Status := FALSE;
        Drone2Status := TRUE;
        Drone3Status := FALSE;
        ChargingStationStatus := TRUE;
        DroneDeployed := FALSE;
        
        (* Check recall condition *)
        IF (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10) THEN
            recallTriggered := TRUE;
            state := 0;
        ELSIF TimeRemaining <= T#0s THEN
            state := 0; (* Charging complete *)
        ELSIF DroneDeployed THEN
            state := 4; (* Deployment requested while charging *)
        ELSE
            (* Continue charging *)
            TimeRemaining := TimeRemaining - T#1ms; (* Decrement time - adjust cycle time as needed *)
        END_IF;
        
    3: (* CHARGING_DRONE3 *)
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := TRUE;
        ChargingStationStatus := TRUE;
        DroneDeployed := FALSE;
        
        (* Check recall condition *)
        IF (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10) THEN
            recallTriggered := TRUE;
            state := 0;
        ELSIF TimeRemaining <= T#0s THEN
            state := 0; (* Charging complete *)
        ELSIF DroneDeployed THEN
            state := 4; (* Deployment requested while charging *)
        ELSE
            (* Continue charging *)
            TimeRemaining := TimeRemaining - T#1ms; (* Decrement time - adjust cycle time as needed *)
        END_IF;
        
    4: (* DEPLOYED *)
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        ChargingStationStatus := FALSE;
        DroneDeployed := TRUE;
        
        (* Check recall condition - if any battery < 10%, force recall *)
        IF (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10) THEN
            DroneDeployed := FALSE;
            state := 0;
        ELSIF NOT DroneDeployed THEN
            state := 0; (* Deployment ended externally *)
        END_IF;
        
END_CASE;

prevState := state;

END_FUNCTION_BLOCK
END_ST