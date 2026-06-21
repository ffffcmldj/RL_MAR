ructured-text
START_ST
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
    state : INT; (* THE STATE VARIABLE *)
    prevState : INT; (* THE PREVIOUS STATE VARIABLE *)
END_VAR

(* STATE DEFINITIONS *)
CONST
    STATE_INITIALIZE : INT := 0;
    STATE_MOTION_DETECTED : INT := 1;
    STATE_AMBIENT_LIGHT_LOW_ENERGY_SAVING_OFF : INT := 2;
    STATE_AMBIENT_LIGHT_LOW_ENERGY_SAVING_ON : INT := 3;
    STATE_AMBIENT_LIGHT_ADEQUATE_ENERGY_SAVING_OFF : INT := 4;
    STATE_AMBIENT_LIGHT_ADEQUATE_ENERGY_SAVING_ON : INT := 5;
END_CONST

(* INITIAL STATE *)
state := STATE_INITIALIZE;

(* CONTROL LOGIC *)
IF MotionSensor THEN
    Light := TRUE;
    EnergyMode := FALSE;
    state := STATE_MOTION_DETECTED;
ELSE
    EnergyMode := EnergySaving;
    
    CASE state OF
        STATE_INITIALIZE:
            IF AmbientLight < 50.0 AND NOT EnergySaving THEN
                Light := TRUE;
                state := STATE_AMBIENT_LIGHT_LOW_ENERGY_SAVING_OFF;
            ELSIF AmbientLight < 50.0 AND EnergySaving THEN
                Light := FALSE;
                state := STATE_AMBIENT_LIGHT_LOW_ENERGY_SAVING_ON;
            ELSIF AmbientLight >= 50.0 AND NOT EnergySaving THEN
                Light := FALSE;
                state := STATE_AMBIENT_LIGHT_ADEQUATE_ENERGY_SAVING_OFF;
            ELSIF AmbientLight >= 50.0 AND EnergySaving THEN
                Light := FALSE;
                state := STATE_AMBIENT_LIGHT_ADEQUATE_ENERGY_SAVING_ON;
            END_IF;
        STATE_MOTION_DETECTED:
            IF NOT MotionSensor THEN
                state := STATE_INITIALIZE;
            END_IF;
        STATE_AMBIENT_LIGHT_LOW_ENERGY_SAVING_OFF:
            Light := TRUE;
        STATE_AMBIENT_LIGHT_LOW_ENERGY_SAVING_ON:
            Light := FALSE;
        STATE_AMBIENT_LIGHT_ADEQUATE_ENERGY_SAVING_OFF:
            Light := FALSE;
        STATE_AMBIENT_LIGHT_ADEQUATE_ENERGY_SAVING_ON:
            Light := FALSE;
    END_CASE;
END_IF;

END_FUNCTION_BLOCK
END_ST