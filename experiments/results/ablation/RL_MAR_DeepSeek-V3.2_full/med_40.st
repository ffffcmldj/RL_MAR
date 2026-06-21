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
    (* No internal variables required for basic logic *)
END_VAR

(* Main logic body *)
IF UserWeightSensor > 60.0 THEN
    ClimbingMotorSpeed := 1.0;
ELSE
    ClimbingMotorSpeed := 0.8;
END_IF;

CASE RouteSelector OF
    1: WallDifficultyLevel := 1;
    2: WallDifficultyLevel := 2;
    3: WallDifficultyLevel := 3;
    ELSE
        WallDifficultyLevel := 0;
END_CASE;

IF WallHeight > 5.0 THEN
    WallLights := TRUE;
ELSE
    WallLights := FALSE;
END_IF;

END_FUNCTION_BLOCK;