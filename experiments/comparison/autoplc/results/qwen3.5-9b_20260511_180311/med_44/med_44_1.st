FUNCTION_BLOCK DroneChargingStation
VAR_INPUT
    Drone1BatteryLevel : INT := 0;
    Drone2BatteryLevel : INT := 0;
    Drone3BatteryLevel : INT := 0;
    ChargingTime : TIME := T#30s;
END_VAR
VAR_OUTPUT
    Drone1Status : BOOL := FALSE;
    Drone2Status : BOOL := FALSE;
    Drone3Status : BOOL := FALSE;
    ChargingStationStatus : BOOL := FALSE;
    DroneDeployed : BOOL := FALSE;
END_VAR
VAR
    TimeRemaining : TIME := T#0s;
    i : INT;
    ActiveDroneIndex : INT;
    LowBatteryRecall : BOOL;
END_VAR

IF ChargingStationStatus = TRUE THEN
    IF TimeRemaining > T#0s THEN
        TimeRemaining := TimeRemaining - T#1s;
    END_IF;

    IF TimeRemaining <= T#0s THEN
        ChargingStationStatus := FALSE;
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        TimeRemaining := T#0s;
    END_IF;

    LowBatteryRecall := FALSE;
    IF Drone1BatteryLevel < 10 THEN
        LowBatteryRecall := TRUE;
    END_IF;
    IF Drone2BatteryLevel < 10 THEN
        LowBatteryRecall := TRUE;
    END_IF;
    IF Drone3BatteryLevel < 10 THEN
        LowBatteryRecall := TRUE;
    END_IF;

    IF LowBatteryRecall = TRUE THEN
        DroneDeployed := FALSE;
    END_IF;

    IF Drone1Status = TRUE THEN
        DroneDeployed := TRUE;
    END_IF;
    IF Drone2Status = TRUE THEN
        DroneDeployed := TRUE;
    END_IF;
    IF Drone3Status = TRUE THEN
        DroneDeployed := TRUE;
    END_IF;

ELSIF ChargingStationStatus = FALSE THEN
    ActiveDroneIndex := 0;
    i := 1;
    WHILE i <= 3 AND ActiveDroneIndex = 0 DO
        IF i = 1 THEN
            IF Drone1BatteryLevel < 20 THEN
                ActiveDroneIndex := 1;
            END_IF;
        ELSIF i = 2 THEN
            IF Drone2BatteryLevel < 20 THEN
                ActiveDroneIndex := 2;
            END_IF;
        ELSIF i = 3 THEN
            IF Drone3BatteryLevel < 20 THEN
                ActiveDroneIndex := 3;
            END_IF;
        END_IF;
        i := i + 1;
    END_WHILE;

    IF ActiveDroneIndex = 1 THEN
        Drone1Status := TRUE;
        ChargingStationStatus := TRUE;
        TimeRemaining := ChargingTime;
        DroneDeployed := TRUE;
    ELSIF ActiveDroneIndex = 2 THEN
        Drone2Status := TRUE;
        ChargingStationStatus := TRUE;
        TimeRemaining := ChargingTime;
        DroneDeployed := TRUE;
    ELSIF ActiveDroneIndex = 3 THEN
        Drone3Status := TRUE;
        ChargingStationStatus := TRUE;
        TimeRemaining := ChargingTime;
        DroneDeployed := TRUE;
    ELSE
        Drone1Status := FALSE;
        Drone2Status := FALSE;
        Drone3Status := FALSE;
        ChargingStationStatus := FALSE;
        TimeRemaining := T#0s;
        DroneDeployed := FALSE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK