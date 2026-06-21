START_ST
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

CASE State OF
    0: // INITIALIZATION
        MotorForward := FALSE;
        MotorReverse := FALSE;
        CompletionLight := FALSE;
        State := 1;

    1: // MANUAL MODE IDLE
        IF NOT Mode THEN
            // Manual mode logic
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
            CompletionLight := FALSE;
            // Remain in State 1 while in manual mode
        ELSE
            // Mode switched to automatic, transition to State 2
            MotorForward := FALSE;
            MotorReverse := FALSE;
            CompletionLight := FALSE;
            State := 2;
        END_IF;

    2: // AUTOMATIC MODE - WAITING AT STATION A
        MotorForward := FALSE;
        MotorReverse := FALSE;
        CompletionLight := FALSE;
        IF NOT Mode THEN
            State := 1; // Switch to manual mode
        ELSIF SensorA THEN
            State := 3; // Transition to processing at station A
        END_IF;

    3: // AUTOMATIC MODE - PROCESSING AT STATION A
        MotorForward := TRUE;
        MotorReverse := FALSE;
        CompletionLight := FALSE;
        IF NOT Mode THEN
            State := 1; // Switch to manual mode
        ELSIF ButtonA THEN
            State := 4; // Transition to moving to station B
        END_IF;

    4: // AUTOMATIC MODE - MOVING TO STATION B
        MotorForward := FALSE;
        MotorReverse := FALSE;
        CompletionLight := FALSE;
        IF NOT Mode THEN
            State := 1; // Switch to manual mode
        ELSIF SensorB THEN
            State := 5; // Transition to processing at station B
        END_IF;

    5: // AUTOMATIC MODE - PROCESSING AT STATION B
        MotorForward := TRUE;
        MotorReverse := FALSE;
        CompletionLight := FALSE;
        IF NOT Mode THEN
            State := 1; // Switch to manual mode
        ELSIF ButtonB THEN
            State := 6; // Transition to moving to station C
        END_IF;

    6: // AUTOMATIC MODE - MOVING TO STATION C
        MotorForward := FALSE;
        MotorReverse := FALSE;
        CompletionLight := FALSE;
        IF NOT Mode THEN
            State := 1; // Switch to manual mode
        ELSIF SensorC THEN
            State := 7; // Transition to processing at station C
        END_IF;

    7: // AUTOMATIC MODE - PROCESSING AT STATION C
        MotorForward := FALSE;
        MotorReverse := FALSE;
        CompletionLight := TRUE;
        IF NOT Mode THEN
            State := 1; // Switch to manual mode
        ELSIF ButtonC THEN
            State := 8; // Transition to cycle completion
        END_IF;

    8: // AUTOMATIC MODE - CYCLE COMPLETION
        MotorForward := FALSE;
        MotorReverse := FALSE;
        CompletionLight := FALSE;
        IF NOT Mode THEN
            State := 1; // Switch to manual mode
        ELSIF NOT SensorC THEN
            State := 2; // Product removed, restart automatic cycle
        END_IF;
END_CASE;

END_FUNCTION_BLOCK
END_ST