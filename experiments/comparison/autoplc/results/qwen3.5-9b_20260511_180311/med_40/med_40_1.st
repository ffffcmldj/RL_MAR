FUNCTION_BLOCK RockClimbingWallControl
VAR_INPUT
    UserWeightSensor : REAL;
    WallDifficultyLevel : INT;
    WallHeight : REAL;
    RouteSelector : INT;
END_VAR
VAR_OUTPUT
    ClimbingMotorSpeed : REAL;
    WallLights : BOOL;
END_VAR
VAR
    TempDifficulty : INT;
END_VAR

IF UserWeightSensor > 60.0 THEN
    ClimbingMotorSpeed := 1.0;
ELSE
    ClimbingMotorSpeed := 0.8;
END_IF;

IF WallHeight > 5.0 THEN
    WallLights := TRUE;
ELSE
    WallLights := FALSE;
END_IF;

TempDifficulty := 1;
IF RouteSelector = 1 THEN
    TempDifficulty := 1;
ELSIF RouteSelector = 2 THEN
    TempDifficulty := 2;
ELSIF RouteSelector = 3 THEN
    TempDifficulty := 3;
END_IF;

WallDifficultyLevel := TempDifficulty;

END_FUNCTION_BLOCK