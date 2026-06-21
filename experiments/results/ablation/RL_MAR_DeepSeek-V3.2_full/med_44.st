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
    CurrentState : INT := 0; (* 0=IDLE, 1=CHARGING_DRONE1, 2=CHARGING_DRONE2, 3=CHARGING_DRONE3 *)
    NextState : INT := 0; (* Next state for state machine *)
    RecallCondition : BOOL := FALSE; (* Battery < 10% recall condition *)
END_VAR

(* Main state machine logic *)
RecallCondition := (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10);

CASE CurrentState OF
    0: (* IDLE STATE *)
        (* Reset all drone charging statuses *)
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        ChargingStationStatus := FALSE;
        
        (* Check for deployment recall condition *)
        IF DroneDeployed AND RecallCondition THEN
            DroneDeployed := FALSE;
        END_IF;
        
        (* Determine next state *)
        IF NOT DroneDeployed THEN
            (* Check for drones needing charging in priority order *)
            IF Drone1BatteryLevel < 20 THEN
                NextState := 1;  (* Start charging Drone 1 *)
                TimeRemaining := ChargingTime;
            ELSIF Drone2BatteryLevel < 20 THEN
                NextState := 2;  (* Start charging Drone 2 *)
                TimeRemaining := ChargingTime;
            ELSIF Drone3BatteryLevel < 20 THEN
                NextState := 3;  (* Start charging Drone 3 *)
                TimeRemaining := ChargingTime;
            ELSE
                NextState := 0;  (* Stay in IDLE *)
            END_IF;
        ELSE
            NextState := 0;  (* Stay in IDLE if drone is deployed *)
        END_IF;
        
    1: (* CHARGING_DRONE1 STATE *)
        (* Set charging status for Drone 1 only *)
        Drone1Status := TRUE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        ChargingStationStatus := TRUE;
        
        (* Decrement charging timer *)
        IF TimeRemaining > T#0s THEN
            TimeRemaining := TimeRemaining - T#1ms;
        END_IF;
        
        (* Determine next state *)
        IF TimeRemaining <= T#0s THEN
            NextState := 0;  (* Return to IDLE when charging complete *)
        ELSIF DroneDeployed AND RecallCondition THEN
            DroneDeployed := FALSE;
            NextState := 0;  (* Return to IDLE for recall *)
        ELSE
            NextState := 1;  (* Continue charging *)
        END_IF;
        
    2: (* CHARGING_DRONE2 STATE *)
        (* Set charging status for Drone 2 only *)
        Drone1Status := FALSE;
        Drone2Status := TRUE;
        Drone3Status := FALSE;
        ChargingStationStatus := TRUE;
        
        (* Decrement charging timer *)
        IF TimeRemaining > T#0s THEN
            TimeRemaining := TimeRemaining - T#1ms;
        END_IF;
        
        (* Determine next state *)
        IF TimeRemaining <= T#0s THEN
            NextState := 0;  (* Return to IDLE when charging complete *)
        ELSIF DroneDeployed AND RecallCondition THEN
            DroneDeployed := FALSE;
            NextState := 0;  (* Return to IDLE for recall *)
        ELSE
            NextState := 2;  (* Continue charging *)
        END_IF;
        
    3: (* CHARGING_DRONE3 STATE *)
        (* Set charging status for Drone 3 only *)
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := TRUE;
        ChargingStationStatus := TRUE;
        
        (* Decrement charging timer *)
        IF TimeRemaining > T#0s THEN
            TimeRemaining := TimeRemaining - T#1ms;
        END_IF;
        
        (* Determine next state *)
        IF TimeRemaining <= T#0s THEN
            NextState := 0;  (* Return to IDLE when charging complete *)
        ELSIF DroneDeployed AND RecallCondition THEN
            DroneDeployed := FALSE;
            NextState := 0;  (* Return to IDLE for recall *)
        ELSE
            NextState := 3;  (* Continue charging *)
        END_IF;
        
    ELSE
        (* Default case - return to IDLE *)
        NextState := 0;
END_CASE;

(* Update current state for next cycle *)
CurrentState := NextState;

END_FUNCTION_BLOCK;