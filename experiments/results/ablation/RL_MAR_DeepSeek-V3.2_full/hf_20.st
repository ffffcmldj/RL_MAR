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
END_VAR

IF State = 0 THEN
    MotorForward := FALSE;
    MotorReverse := FALSE;
    CompletionLight := FALSE;
    State := 1;
END_IF;

IF NOT Mode THEN
    IF ForwardButton AND NOT ReverseButton THEN
        MotorForward := TRUE;
        MotorReverse := FALSE;
    ELSIF ReverseButton AND NOT ForwardButton THEN
        MotorForward := FALSE;
        MotorReverse := TRUE;
    ELSE
        MotorForward := FALSE;
        MotorReverse := FALSE;
    END_IF;
ELSE
    CASE State OF
        1:
            IF SensorA THEN
                State := 2;
            END_IF;
        2:
            IF ButtonA THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
                State := 3;
            END_IF;
        3:
            IF SensorB THEN
                MotorForward := FALSE;
                State := 4;
            END_IF;
        4:
            IF ButtonB THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
                State := 5;
            END_IF;
        5:
            IF SensorC THEN
                MotorForward := FALSE;
                State := 6;
            END_IF;
        6:
            IF ButtonC THEN
                CompletionLight := TRUE;
                State := 7;
            END_IF;
        7:
            IF NOT SensorC THEN
                CompletionLight := FALSE;
                State := 1;
            END_IF;
    END_CASE;
END_IF;

END_FUNCTION_BLOCK;