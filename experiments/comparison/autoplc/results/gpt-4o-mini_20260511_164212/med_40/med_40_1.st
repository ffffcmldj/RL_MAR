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
    DifficultyLevel : INT; (* Variable to hold the difficulty level based on route selection *)
END_VAR

(* Initialization of output variables *)
ClimbingMotorSpeed := 0.0; 
WallLights := FALSE; 

(* Motor Speed Adjustment Logic *)
IF UserWeightSensor > 60.0 THEN
    ClimbingMotorSpeed := 1.0; (* Set motor speed for users over 60 kg *)
ELSE
    ClimbingMotorSpeed := 0.8; (* Set motor speed for users 60 kg or less *)
END_IF;

(* Wall Lighting Control Logic *)
IF WallHeight > 5.0 THEN
    WallLights := TRUE; (* Activate lights if wall height exceeds 5.0 meters *)
ELSE
    WallLights := FALSE; (* Deactivate lights if wall height is 5.0 meters or less *)
END_IF;

(* Difficulty Level Setting Logic based on RouteSelector *)
CASE RouteSelector OF
    1: DifficultyLevel := 1; (* Route 1 corresponds to difficulty level 1 *)
    2: DifficultyLevel := 2; (* Route 2 corresponds to difficulty level 2 *)
    3: DifficultyLevel := 3; (* Route 3 corresponds to difficulty level 3 *)
    ELSE
        DifficultyLevel := 0; (* Default case if RouteSelector is invalid *)
END_CASE;

(* Update the WallDifficultyLevel output variable *)
WallDifficultyLevel := DifficultyLevel;

END_FUNCTION_BLOCK