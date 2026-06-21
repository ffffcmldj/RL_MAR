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
    state : INT; (* Current state: 0 = INITIALIZE, 1 = OPERATIONAL *)
    prevState : INT; (* Previous state for tracking changes *)
    effectiveDifficulty : INT; (* Internal difficulty level based on RouteSelector *)
END_VAR

(* State machine logic *)
CASE state OF
    0: (* INITIALIZE *)
        (* Set outputs to default safe values *)
        ClimbingMotorSpeed := 0.0;
        WallLights := FALSE;
        effectiveDifficulty := 1; (* Default difficulty *)
        (* Transition to OPERATIONAL state *)
        state := 1;

    1: (* OPERATIONAL *)
        (* Calculate effective difficulty based on RouteSelector *)
        IF RouteSelector = 1 THEN
            effectiveDifficulty := 1;
        ELSIF RouteSelector = 2 THEN
            effectiveDifficulty := 2;
        ELSIF RouteSelector = 3 THEN
            effectiveDifficulty := 3;
        ELSE
            effectiveDifficulty := 1; (* Default to 1 if invalid *)
        END_IF;

        (* Set ClimbingMotorSpeed based on UserWeightSensor *)
        IF UserWeightSensor > 60.0 THEN
            ClimbingMotorSpeed := 1.0;
        ELSE
            ClimbingMotorSpeed := 0.8;
        END_IF;

        (* Set WallLights based on WallHeight *)
        IF WallHeight > 5.0 THEN
            WallLights := TRUE;
        ELSE
            WallLights := FALSE;
        END_IF;

        (* Remain in OPERATIONAL state *)
        state := 1;

    ELSE
        (* Fallback: reinitialize to safe state *)
        state := 0;
END_CASE;

(* Update previous state for tracking *)
prevState := state;

END_FUNCTION_BLOCK
END_ST