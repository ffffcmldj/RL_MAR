START_ST
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
    CurrentWeight : REAL; // Copy of UserWeightSensor
    CurrentHeight : REAL; // Copy of WallHeight
    CurrentRoute : INT;   // Copy of RouteSelector
    TargetDifficulty : INT; // Internal variable to map RouteSelector to Difficulty
    MotorSpeed : REAL;    // Internal variable for ClimbingMotorSpeed
    LightsOn : BOOL;      // Internal variable for WallLights
    WEIGHT_THRESHOLD : REAL := 60.0;
    HEIGHT_THRESHOLD : REAL := 5.0;
END_VAR

    (* STATE 0: INITIALIZE - System Ready *)
    (* Logic: Upon entering the function block, ensure inputs are captured *)
    CurrentWeight := UserWeightSensor;
    CurrentHeight := WallHeight;
    CurrentRoute := RouteSelector;

    (* STATE 1: CALCULATE MOTOR SPEED (Based on Weight) *)
    (* Logic: Adjust speed based on weight threshold *)
    IF CurrentWeight > WEIGHT_THRESHOLD THEN
        MotorSpeed := 1.0;
    ELSE
        MotorSpeed := 0.8;
    END_IF;

    (* STATE 2: CALCULATE LIGHTS (Based on Height) *)
    (* Logic: Activate lights if height exceeds threshold *)
    IF CurrentHeight > HEIGHT_THRESHOLD THEN
        LightsOn := TRUE;
    ELSE
        LightsOn := FALSE;
    END_IF;

    (* STATE 3: UPDATE ROUTE DIFFICULTY (Based on Route Selector) *)
    (* Logic: Map RouteSelector to internal TargetDifficulty *)
    (* Route 1 -> Level 1, Route 2 -> Level 2, Route 3 -> Level 3 *)
    IF CurrentRoute = 1 THEN
        TargetDifficulty := 1;
    ELSIF CurrentRoute = 2 THEN
        TargetDifficulty := 2;
    ELSIF CurrentRoute = 3 THEN
        TargetDifficulty := 3;
    ELSE
        TargetDifficulty := 0; (* Default or invalid route *)
    END_IF;

    (* Assign outputs *)
    ClimbingMotorSpeed := MotorSpeed;
    WallLights := LightsOn;

END_FUNCTION_BLOCK
END_ST