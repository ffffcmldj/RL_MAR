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
    nCurrentDifficulty : INT;
    rSpeedMultiplier : REAL;
END_VAR

(* Determine motor speed multiplier based on user weight *)
IF UserWeightSensor > 60.0 THEN
    rSpeedMultiplier := 1.0;
ELSE
    rSpeedMultiplier := 0.8;
END_IF;

(* Determine current difficulty level based on route selection *)
CASE RouteSelector OF
    1: nCurrentDifficulty := 1;
    2: nCurrentDifficulty := 2;
    3: nCurrentDifficulty := 3;
    ELSE
        nCurrentDifficulty := WallDifficultyLevel;
END_CASE;

(* Calculate final motor speed: multiplier * (1.0 + 0.1*(difficulty-1)) *)
ClimbingMotorSpeed := rSpeedMultiplier * (1.0 + (0.1 * (nCurrentDifficulty - 1)));

(* Control wall lights based on wall height *)
IF WallHeight > 5.0 THEN
    WallLights := TRUE;
ELSE
    WallLights := FALSE;
END_IF;

END_FUNCTION_BLOCK