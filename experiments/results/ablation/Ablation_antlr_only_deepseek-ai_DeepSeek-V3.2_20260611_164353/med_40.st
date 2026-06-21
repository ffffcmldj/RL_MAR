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
    InternalWeightThreshold : REAL := 60.0;
    InternalHeightThreshold : REAL := 5.0;
    InternalRouteLevel : INT;
    InternalMotorSpeedAdjust : REAL;
    InternalLightCondition : BOOL;
END_VAR

(* Route-based difficulty level assignment *)
CASE RouteSelector OF
    1: InternalRouteLevel := 1;
    2: InternalRouteLevel := 2;
    3: InternalRouteLevel := 3;
ELSE
    InternalRouteLevel := WallDifficultyLevel; (* Fallback to initial difficulty level *)
END_CASE;

(* Motor speed adjustment based on user weight *)
IF UserWeightSensor > InternalWeightThreshold THEN
    InternalMotorSpeedAdjust := 1.0;
ELSE
    InternalMotorSpeedAdjust := 0.8;
END_IF;

(* Wall lighting control based on wall height *)
IF WallHeight > InternalHeightThreshold THEN
    InternalLightCondition := TRUE;
ELSE
    InternalLightCondition := FALSE;
END_IF;

(* Assign final output values *)
ClimbingMotorSpeed := InternalMotorSpeedAdjust;
WallLights := InternalLightCondition;

END_FUNCTION_BLOCK