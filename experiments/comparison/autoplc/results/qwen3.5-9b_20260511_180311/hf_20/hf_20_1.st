FUNCTION_BLOCK FB_ProductionLineControl
VAR_INPUT
    Mode : BOOL;
    ForwardButton : BOOL;
    ReverseButton : BOOL;
    SensorA : BOOL;
    SensorB : BOOL;
    SensorC : BOOL;
    ButtonA : BOOL;
    ButtonB : BOOL;
    ButtonC : BOOL;
END_VAR
VAR_OUTPUT
    MotorForward : BOOL;
    MotorReverse : BOOL;
    CompletionLight : BOOL;
END_VAR
VAR
    State : INT;
    PrevSensorA : BOOL;
    PrevButtonA : BOOL;
    PrevSensorB : BOOL;
    PrevButtonB : BOOL;
    PrevSensorC : BOOL;
    PrevButtonC : BOOL;
    PrevSensorC_Reset : BOOL;
END_VAR

State := 0;
PrevSensorA := FALSE;
PrevButtonA := FALSE;
PrevSensorB := FALSE;
PrevButtonB := FALSE;
PrevSensorC := FALSE;
PrevButtonC := FALSE;
PrevSensorC_Reset := FALSE;

IF State = 0 THEN
    MotorForward := FALSE;
    MotorReverse := FALSE;
    CompletionLight := FALSE;
    State := 1;
ELSIF Mode = FALSE THEN
    IF ForwardButton = TRUE AND ReverseButton = FALSE THEN
        MotorForward := TRUE;
        MotorReverse := FALSE;
    ELSIF ReverseButton = TRUE AND ForwardButton = FALSE THEN
        MotorForward := FALSE;
        MotorReverse := TRUE;
    ELSE
        MotorForward := FALSE;
        MotorReverse := FALSE;
    END_IF;
ELSE
    IF State = 1 THEN
        IF SensorA = TRUE AND PrevSensorA = FALSE THEN
            State := 2;
        END_IF;
    ELSIF State = 2 THEN
        MotorForward := FALSE;
        MotorReverse := FALSE;
        IF ButtonA = TRUE AND PrevButtonA = FALSE THEN
            MotorForward := TRUE;
            MotorReverse := FALSE;
            State := 3;
        END_IF;
    ELSIF State = 3 THEN
        MotorForward := FALSE;
        MotorReverse := FALSE;
        IF SensorB = TRUE AND PrevSensorB = FALSE THEN
            State := 4;
        END_IF;
    ELSIF State = 4 THEN
        MotorForward := FALSE;
        MotorReverse := FALSE;
        IF ButtonB = TRUE AND PrevButtonB = FALSE THEN
            MotorForward := TRUE;
            MotorReverse := FALSE;
            State := 5;
        END_IF;
    ELSIF State = 5 THEN
        MotorForward := FALSE;
        MotorReverse := FALSE;
        IF SensorC = TRUE AND PrevSensorC = FALSE THEN
            State := 6;
        END_IF;
    ELSIF State = 6 THEN
        MotorForward := FALSE;
        MotorReverse := FALSE;
        CompletionLight := FALSE;
        IF ButtonC = TRUE AND PrevButtonC = FALSE THEN
            MotorForward := TRUE;
            MotorReverse := FALSE;
            CompletionLight := TRUE;
            State := 7;
        END_IF;
    ELSIF State = 7 THEN
        CompletionLight := FALSE;
        IF SensorC = FALSE AND PrevSensorC = TRUE THEN
            State := 1;
        END_IF;
    END_IF;
END_IF;

PrevSensorA := SensorA;
PrevButtonA := ButtonA;
PrevSensorB := SensorB;
PrevButtonB := ButtonB;
PrevSensorC := SensorC;
PrevButtonC := ButtonC;
PrevSensorC_Reset := SensorC;

END_FUNCTION_BLOCK