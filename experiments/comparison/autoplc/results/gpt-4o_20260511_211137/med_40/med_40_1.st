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
    DefaultMotorSpeed : REAL := 0.0; (* Default motor speed initialization *)
    DefaultWallLights : BOOL := FALSE; (* Default wall lights initialization *)
END_VAR

(* Initialization *)
ClimbingMotorSpeed := DefaultMotorSpeed;
WallLights := DefaultWallLights;

(* Motor Speed Adjustment based on User Weight *)
IF UserWeightSensor > 60.0 THEN
    ClimbingMotorSpeed := 1.0;
ELSE
    ClimbingMotorSpeed := 0.8;
END_IF;

(* Difficulty Level Setting based on Route Selection *)
CASE RouteSelector OF
    1: WallDifficultyLevel := 1;
    2: WallDifficultyLevel := 2;
    3: WallDifficultyLevel := 3;
ELSE
    (* Default case if RouteSelector is not 1, 2, or 3 *)
    WallDifficultyLevel := 0; (* Assuming 0 as a default or error state *)
END_CASE;

(* Wall Lights Control based on Wall Height *)
IF WallHeight > 5.0 THEN
    WallLights := TRUE;
ELSE
    WallLights := FALSE;
END_IF;

END_FUNCTION_BLOCK