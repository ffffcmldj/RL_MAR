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
    internalDifficultyLevel : INT; (* Internal variable for calculated difficulty level *)
END_VAR

(* Main execution logic *)

(* Set difficulty level based on route selector *)
CASE RouteSelector OF
    1: internalDifficultyLevel := 1;
    2: internalDifficultyLevel := 2;
    3: internalDifficultyLevel := 3;
    ELSE
        (* Fallback to input difficulty level if route selector is invalid *)
        internalDifficultyLevel := WallDifficultyLevel;
END_CASE;

(* Adjust climbing motor speed based on user weight *)
IF UserWeightSensor > 60.0 THEN
    ClimbingMotorSpeed := 1.0;
ELSE
    ClimbingMotorSpeed := 0.8;
END_IF;

(* Control wall lights based on wall height *)
IF WallHeight > 5.0 THEN
    WallLights := TRUE;
ELSE
    WallLights := FALSE;
END_IF;

END_FUNCTION_BLOCK