plaintext
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
    state : INT; (* The current state of the FSM *)
    prevState : INT; (* The previous state of the FSM *)
END_VAR

(* Initialization *)
IF state = 0 THEN
    ClimbingMotorSpeed := 0.0;
    WallLights := FALSE;
    state := 1; (* Transition to STATE 1: ADJUST MOTOR SPEED *)
END_IF

(* State 1: Adjust Motor Speed *)
IF state = 1 THEN
    IF UserWeightSensor > 60.0 THEN
        ClimbingMotorSpeed := 1.0;
    ELSE
        ClimbingMotorSpeed := 0.8;
    END_IF;
    state := 2; (* Transition to STATE 2: SET DIFFICULTY LEVEL *)
END_IF

(* State 2: Set Difficulty Level *)
IF state = 2 THEN
    CASE RouteSelector OF
        1: WallDifficultyLevel := 1;
        2: WallDifficultyLevel := 2;
        3: WallDifficultyLevel := 3;
        ELSE
            WallDifficultyLevel := WallDifficultyLevel; (* Keep the current level if invalid route *)
    END_CASE;
    state := 3; (* Transition to STATE 3: CONTROL WALL LIGHTS *)
END_IF

(* State 3: Control Wall Lights *)
IF state = 3 THEN
    IF WallHeight > 5.0 THEN
        WallLights := TRUE;
    ELSE
        WallLights := FALSE;
    END_IF;
    state := 1; (* Loop back to STATE 1: ADJUST MOTOR SPEED *)
END_IF

END_FUNCTION_BLOCK
END_ST