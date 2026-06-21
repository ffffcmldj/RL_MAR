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
    tempThreshold : REAL := 20.0; (* Constant for temperature check *)
    conditionRainAndWind : BOOL; (* Temporary flag for highest priority check *)
    conditionRainOnly : BOOL; (* Temporary flag for rain check *)
    conditionLowTemp : BOOL; (* Temporary flag for temperature check *)
END_VAR

    (* STATE 2: CLOSE ROOF (Rain + Wind) - Highest Priority *)
    conditionRainAndWind := RainSensor AND WindSensor;

    (* STATE 1: CLOSE ROOF (Rain Only) *)
    conditionRainOnly := RainSensor AND NOT conditionRainAndWind;

    (* STATE 3: CLOSE ROOF (Low Temp) *)
    conditionLowTemp := NOT conditionRainAndWind AND NOT conditionRainOnly AND (TemperatureSensor < tempThreshold);

    (* STATE 0: IDLE / NORMAL (Default State) *)
    (* Implicitly handled if no other conditions are met *)

    (* Assign Output based on evaluated states *)
    IF conditionRainAndWind THEN
        RoofMotor := TRUE;
    ELSIF conditionRainOnly THEN
        RoofMotor := TRUE;
    ELSIF conditionLowTemp THEN
        RoofMotor := TRUE;
    ELSE
        RoofMotor := FALSE;
    END_IF;

END_FUNCTION_BLOCK
END_ST