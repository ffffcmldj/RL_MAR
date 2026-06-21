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

VAR
    (* No internal variables needed for this simple logic *)
END_VAR

(* Main logic body *)
IF MotionSensor THEN
    (* Motion Detection Override: Highest priority *)
    Light := TRUE;
    EnergyMode := FALSE; (* Override: deactivate energy-saving mode *)
ELSE
    (* No motion detected: evaluate ambient light and energy-saving mode *)
    IF (AmbientLight < 50.0) AND (NOT EnergySaving) THEN
        Light := TRUE;
    ELSE
        Light := FALSE;
    END_IF;
    
    (* Energy mode status reflects the input *)
    EnergyMode := EnergySaving;
END_IF;

END_FUNCTION_BLOCK;