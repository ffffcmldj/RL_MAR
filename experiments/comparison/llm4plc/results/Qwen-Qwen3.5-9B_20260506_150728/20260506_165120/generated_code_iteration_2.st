

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
    CurrentState : INT := 0; (* 0:IDLE, 1:CHARGING_D1, 2:CHARGING_D2, 3:CHARGING_D3, 4:DEPLOYED *)
    TimeRemaining : TIME := ChargingTime; (* Remaining charging time *)
    RecallTriggered : BOOL := FALSE; (* Internal flag to handle recall logic *)
END_VAR

BEGIN
    (* --- STATE MACHINE LOGIC --- *)

    (* State 0: IDLE - Check for charging needs *)
    IF CurrentState = 0 THEN
        BEGIN
            (* Priority: Drone 1, then Drone 2, then Drone 3 *)
            IF Drone1BatteryLevel < 20 THEN
                CurrentState := 1;
            ELSEIF Drone2BatteryLevel < 20 THEN
                CurrentState := 2;
            ELSEIF Drone3BatteryLevel < 20 THEN
                CurrentState := 3;
            ELSE
                (* No drone needs charging, remain in IDLE *)
                CurrentState := 0;
            END_IF;
        END;
    END_IF;

    (* State 1: CHARGING_DRONE1 *)
    IF CurrentState = 1 THEN
        BEGIN
            IF TimeRemaining > T#0s THEN
                TimeRemaining := TimeRemaining - T#1s;
            ELSE
                (* Charging Complete *)
                TimeRemaining := ChargingTime;
                CurrentState := 0;
            END_IF;
        END;
    END_IF;

    (* State 2: CHARGING_DRONE2 *)
    IF CurrentState = 2 THEN
        BEGIN
            IF TimeRemaining > T#0s THEN
                TimeRemaining := TimeRemaining - T#1s;
            ELSE
                (* Charging Complete *)
                TimeRemaining := ChargingTime;
                CurrentState := 0;
            END_IF;
        END;
    END_IF;

    (* State 3: CHARGING_DRONE3 *)
    IF CurrentState = 3 THEN
        BEGIN
            IF TimeRemaining > T#0s THEN
                TimeRemaining := TimeRemaining - T#1s;
            ELSE
                (* Charging Complete *)
                TimeRemaining := ChargingTime;
                CurrentState := 0;
            END_IF;
        END;
    END_IF;

    (* State 4: DEPLOYED - Monitor for Recall *)
    (* Logic: If in State 4, check if any drone battery is critically low (< 10%) to trigger recall. *)
    IF CurrentState = 4 THEN
        BEGIN
            IF (Drone1BatteryLevel < 10) OR (Drone2BatteryLevel < 10) OR (Drone3BatteryLevel < 10) THEN
                (* Recall Triggered: Return to IDLE *)
                CurrentState := 0;
                RecallTriggered := TRUE;
            ELSE
                (* Continue Monitoring *)
                RecallTriggered := FALSE;
            END_IF;
        END;
    END_IF;

    (* --- OUTPUT ASSIGNMENT LOGIC --- *)

    CASE CurrentState OF
        0: (* IDLE *)
            Drone1Status := FALSE;
            Drone2Status := FALSE;
            Drone3Status := FALSE;
            ChargingStationStatus := FALSE;
            DroneDeployed := FALSE;
            
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
            DroneDeployed := TRUE;
    END_CASE;

END_FUNCTION_BLOCK
END_ST
END_REASON