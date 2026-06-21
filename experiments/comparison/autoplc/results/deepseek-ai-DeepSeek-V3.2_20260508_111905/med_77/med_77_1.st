FUNCTION_BLOCK OutdoorLEDLightingControl
VAR_INPUT
    AmbientLight : REAL;    (* 环境光传感器输入 *)
    MotionSensor : BOOL;    (* 运动传感器输入 *)
    EnergySaving : BOOL;    (* 节能模式开关 *)
END_VAR
VAR_OUTPUT
    Light : BOOL;           (* LED照明控制输出 *)
    EnergyMode : BOOL;      (* 节能模式状态输出 *)
END_VAR


    (* 运动检测覆盖逻辑 *)
    IF MotionSensor THEN
        (* 检测到运动时，打开灯光并禁用节能模式 *)
        Light := TRUE;
        EnergyMode := FALSE;
    ELSE
        (* 无运动检测时，根据环境光和节能模式控制灯光 *)
        EnergyMode := EnergySaving;  (* 节能模式状态反映输入 *)
        
        (* 检查环境光是否低于阈值且节能模式关闭 *)
        IF (AmbientLight < 50.0) AND (NOT EnergySaving) THEN
            Light := TRUE;  (* 打开灯光 *)
        ELSE
            Light := FALSE; (* 关闭灯光 *)
        END_IF;
    END_IF;
END_FUNCTION_BLOCK