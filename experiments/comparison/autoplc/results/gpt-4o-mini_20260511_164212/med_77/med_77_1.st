FUNCTION_BLOCK OutdoorLEDLightingControl
VAR_INPUT
    AmbientLight : REAL; (* 环境光传感器输入 *)
    MotionSensor : BOOL; (* 运动传感器输入 *)
    EnergySaving : BOOL; (* 节能模式开关 *)
END_VAR

VAR_OUTPUT
    Light : BOOL; (* LED照明控制输出 *)
    EnergyMode : BOOL; (* 节能模式状态输出 *)
END_VAR


    // Initialize EnergyMode based on EnergySaving input
    EnergyMode := EnergySaving;

    // Check for motion detection
    IF MotionSensor THEN
        // Motion detected: Turn on lights and deactivate energy-saving mode
        Light := TRUE;
        EnergyMode := FALSE; // Override energy-saving mode
    ELSE
        // No motion detected: Check ambient light and energy-saving mode
        IF AmbientLight < 50.0 AND NOT EnergySaving THEN
            Light := TRUE; // Turn on lights if ambient light is low and energy-saving is off
        ELSE
            Light := FALSE; // Turn off lights otherwise
        END_IF;
    END_IF;
END_FUNCTION_BLOCK