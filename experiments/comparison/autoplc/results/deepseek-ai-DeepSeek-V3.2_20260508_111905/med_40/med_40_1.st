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
    // Internal variables for processing
    tempWeight : REAL;
    tempRoute : INT;
    tempHeight : REAL;
END_VAR

(* Main execution logic *)
(* Process weight sensor input for motor speed *)
tempWeight := UserWeightSensor;
IF tempWeight > 60.0 THEN
    ClimbingMotorSpeed := 1.0;
ELSE
    ClimbingMotorSpeed := 0.8;
END_IF;

(* Process route selector for difficulty level *)
tempRoute := RouteSelector;
CASE tempRoute OF
    1: WallDifficultyLevel := 1;
    2: WallDifficultyLevel := 2;
    3: WallDifficultyLevel := 3;
    ELSE
        (* If route selector is invalid, maintain current difficulty level *)
        (* No change to WallDifficultyLevel *)
END_CASE;

(* Process wall height for lighting control *)
tempHeight := WallHeight;
IF tempHeight > 5.0 THEN
    WallLights := TRUE;
ELSE
    WallLights := FALSE;
END_IF;

END_FUNCTION_BLOCK