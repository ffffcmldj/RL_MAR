FUNCTION_BLOCK RoboticArmColorSorting
VAR_INPUT
    ColorSensorRed : BOOL;
    ColorSensorGreen : BOOL;
    ColorSensorBlue : BOOL;
END_VAR
VAR_OUTPUT
    RoboticArmMove : BOOL := FALSE;
    BinRed : BOOL := FALSE;
    BinGreen : BOOL := FALSE;
    BinBlue : BOOL := FALSE;
END_VAR
VAR
    PriorityIndex : INT := 0;
    SensorCount : INT := 0;
    i : INT;
END_VAR

PriorityIndex := 0;
SensorCount := 0;

IF ColorSensorRed = TRUE THEN
    PriorityIndex := PriorityIndex + 1;
    SensorCount := SensorCount + 1;
END_IF;

IF ColorSensorGreen = TRUE THEN
    PriorityIndex := PriorityIndex + 1;
    SensorCount := SensorCount + 1;
END_IF;

IF ColorSensorBlue = TRUE THEN
    PriorityIndex := PriorityIndex + 1;
    SensorCount := SensorCount + 1;
END_IF;

IF SensorCount = 0 THEN
    RoboticArmMove := FALSE;
    BinRed := FALSE;
    BinGreen := FALSE;
    BinBlue := FALSE;
ELSIF PriorityIndex = 1 THEN
    IF ColorSensorRed = TRUE THEN
        RoboticArmMove := TRUE;
        BinRed := TRUE;
        BinGreen := FALSE;
        BinBlue := FALSE;
    ELSIF ColorSensorGreen = TRUE THEN
        RoboticArmMove := TRUE;
        BinRed := FALSE;
        BinGreen := TRUE;
        BinBlue := FALSE;
    ELSIF ColorSensorBlue = TRUE THEN
        RoboticArmMove := TRUE;
        BinRed := FALSE;
        BinGreen := FALSE;
        BinBlue := TRUE;
    END_IF;
ELSIF PriorityIndex = 2 THEN
    IF ColorSensorRed = TRUE THEN
        RoboticArmMove := TRUE;
        BinRed := TRUE;
        BinGreen := FALSE;
        BinBlue := FALSE;
    ELSIF ColorSensorGreen = TRUE THEN
        RoboticArmMove := TRUE;
        BinRed := FALSE;
        BinGreen := TRUE;
        BinBlue := FALSE;
    ELSIF ColorSensorBlue = TRUE THEN
        RoboticArmMove := TRUE;
        BinRed := FALSE;
        BinGreen := FALSE;
        BinBlue := TRUE;
    END_IF;
ELSIF PriorityIndex = 3 THEN
    IF ColorSensorRed = TRUE THEN
        RoboticArmMove := TRUE;
        BinRed := TRUE;
        BinGreen := FALSE;
        BinBlue := FALSE;
    ELSIF ColorSensorGreen = TRUE THEN
        RoboticArmMove := TRUE;
        BinRed := FALSE;
        BinGreen := TRUE;
        BinBlue := FALSE;
    ELSIF ColorSensorBlue = TRUE THEN
        RoboticArmMove := TRUE;
        BinRed := FALSE;
        BinGreen := FALSE;
        BinBlue := TRUE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK