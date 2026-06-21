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
    InternalDifficultyLevel : INT;
END_VAR

(* Determine motor speed based on user weight *)
IF UserWeightSensor > 60.0 THEN
    ClimbingMotorSpeed := 1.0;
ELSE
    ClimbingMotorSpeed := 0.8;
END_IF;

(* Determine difficulty level based on selected route *)
CASE RouteSelector OF
    1: InternalDifficultyLevel := 1;
    2: InternalDifficultyLevel := 2;
    3: InternalDifficultyLevel := 3;
    ELSE
        InternalDifficultyLevel := WallDifficultyLevel; (* Fallback to input level *)
END_CASE;

(* Control wall lights based on wall height *)
IF WallHeight > 5.0 THEN
    WallLights := TRUE;
ELSE
    WallLights := FALSE;
END_IF;

END_FUNCTION_BLOCK