ructured-text
START_ST
FUNCTION_BLOCK RetractableRoofControl
VAR_INPUT
    RainSensor : BOOL; (* Rain detection *)
    WindSensor : BOOL; (* Wind detection *)
    TemperatureSensor : REAL; (* Temperature input *)
END_VAR
VAR_OUTPUT
    RoofMotor : BOOL; (* Motor control *)
END_VAR
VAR
    state : INT; (* THE STATE VARIABLE *)
    prevState : INT; (* THE PREVIOUS STATE VARIABLE *)
END_VAR

(* STATE DEFINITIONS *)
CONST
    STATE_INITIALIZE : INT := 0;
    STATE_CLOSE_ROOF_RAIN_WIND : INT := 1;
    STATE_CLOSE_ROOF_RAIN_ONLY : INT := 2;
    STATE_CLOSE_ROOF_LOW_TEMP : INT := 3;
    STATE_OPEN_ROOF_NORMAL : INT := 4;
END_CONST

(* INITIAL STATE *)
state := STATE_INITIALIZE;
RoofMotor := FALSE; (* Initial state *)

(* CONTROL LOGIC *)
CASE state OF
    STATE_INITIALIZE:
        IF RainSensor AND WindSensor THEN
            RoofMotor := TRUE; (* Close the roof due to rain and wind *)
            state := STATE_CLOSE_ROOF_RAIN_WIND;
        ELSIF RainSensor AND NOT WindSensor THEN
            RoofMotor := TRUE; (* Close the roof due to rain only *)
            state := STATE_CLOSE_ROOF_RAIN_ONLY;
        ELSIF TemperatureSensor < 20.0 AND NOT RainSensor AND NOT WindSensor THEN
            RoofMotor := TRUE; (* Close the roof due to low temperature *)
            state := STATE_CLOSE_ROOF_LOW_TEMP;
        ELSE
            RoofMotor := FALSE; (* Open the roof under normal conditions *)
            state := STATE_OPEN_ROOF_NORMAL;
        END_IF;

    STATE_CLOSE_ROOF_RAIN_WIND:
        (* Exit condition, reset to initial state if needed *)
        state := STATE_INITIALIZE;

    STATE_CLOSE_ROOF_RAIN_ONLY:
        (* Exit condition, reset to initial state if needed *)
        state := STATE_INITIALIZE;

    STATE_CLOSE_ROOF_LOW_TEMP:
        (* Exit condition, reset to initial state if needed *)
        state := STATE_INITIALIZE;

    STATE_OPEN_ROOF_NORMAL:
        (* Exit condition, reset to initial state if needed *)
        state := STATE_INITIALIZE;

END_CASE;

END_FUNCTION_BLOCK
END_ST