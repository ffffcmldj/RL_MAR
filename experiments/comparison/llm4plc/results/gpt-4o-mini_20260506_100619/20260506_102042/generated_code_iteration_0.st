ructured-text
FUNCTION_BLOCK RockClimbingWallControl
VAR_INPUT
    UserWeightSensor : REAL; (* Input for measuring the user's weight *)
    WallDifficultyLevel : INT; (* Input for setting the wall's initial difficulty level *)
    WallHeight : REAL; (* Input for setting the wall's height *)
    RouteSelector : INT; (* Input for selecting a climbing route *)
END_VAR
VAR_OUTPUT
    ClimbingMotorSpeed : REAL; (* Output for controlling the climbing wall motor speed *)
    WallLights : BOOL; (* Output for controlling wall lighting *)
END_VAR
VAR
    state : INT; (* THE STATE VARIABLE *)
    prevState : INT; (* THE PREVIOUS STATE VARIABLE *)
    UserWeight : REAL; (* THE USER'S WEIGHT *)
    DifficultyLevel : INT; (* THE WALL DIFFICULTY LEVEL *)
    Height : REAL; (* THE WALL HEIGHT *)
    Route : INT; (* THE SELECTED ROUTE *)
END_VAR

(* STATE 0: INITIALIZE *)
IF state = 0 THEN
    ClimbingMotorSpeed := 0.0;
    WallLights := FALSE;
    UserWeight := UserWeightSensor;
    DifficultyLevel := WallDifficultyLevel;
    Height := WallHeight;
    Route := RouteSelector;
    state := 1; (* Transition to STATE 1 *)
END_IF

(* STATE 1: SET_MOTOR_SPEED *)
IF state = 1 THEN
    IF UserWeight > 60.0 THEN
        ClimbingMotorSpeed := 1.0;
    ELSE
        ClimbingMotorSpeed := 0.8;
    END_IF;
    state := 2; (* Transition to STATE 2 *)
END_IF

(* STATE 2: CONTROL_WALL_LIGHTS *)
IF state = 2 THEN
    IF Height > 5.0 THEN
        WallLights := TRUE;
    ELSE
        WallLights := FALSE;
    END_IF;
    state := 1; (* Return to STATE 1 to continuously adjust motor speed based on weight *)
END_IF

END_FUNCTION_BLOCK