FUNCTION_BLOCK FB_ProductionLineControl
    VAR_INPUT 
        Mode : BOOL; // Manual/Auto mode selection
        ForwardButton : BOOL; // Forward rotation button
        ReverseButton : BOOL; // Reverse rotation button
        SensorA : BOOL; // Sensor A input
        SensorB : BOOL; // Sensor B input
        SensorC : BOOL; // Sensor C input
        ButtonA : BOOL; // Button A input
        ButtonB : BOOL; // Button B input
        ButtonC : BOOL; // Button C input
    END_VAR

    VAR_OUTPUT 
        MotorForward : BOOL; // Motor forward output
        MotorReverse : BOOL; // Motor reverse output
        CompletionLight : BOOL; // Process completion indicator
    END_VAR

    VAR 
        State : INT; // State machine current state
    END_VAR

    // Initialization
    IF State = 0 THEN
        MotorForward := FALSE;
        MotorReverse := FALSE;
        CompletionLight := FALSE;
        State := 1;
    ELSE
        // Manual Mode Operation
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
            // Automatic Mode Operation
            CASE State OF
                1: // Waiting at Station A
                    IF SensorA THEN
                        State := 2; // Transition to State 2
                    END_IF;

                2: // Processing at Station A
                    IF ButtonA THEN
                        MotorForward := TRUE;
                        MotorReverse := FALSE;
                        State := 3; // Transition to State 3
                    END_IF;

                3: // Moving to Station B
                    IF SensorB THEN
                        MotorForward := FALSE;
                        State := 4; // Transition to State 4
                    END_IF;

                4: // Processing at Station B
                    IF ButtonB THEN
                        MotorForward := TRUE;
                        MotorReverse := FALSE;
                        State := 5; // Transition to State 5
                    END_IF;

                5: // Moving to Station C
                    IF SensorC THEN
                        MotorForward := FALSE;
                        State := 6; // Transition to State 6
                    END_IF;

                6: // Processing at Station C
                    IF ButtonC THEN
                        CompletionLight := TRUE;
                        State := 7; // Transition to State 7
                    END_IF;

                7: // Cycle Completion
                    IF NOT SensorC THEN
                        CompletionLight := FALSE;
                        State := 1; // Return to State 1
                    END_IF;
            END_CASE;
        END_IF;
    END_IF;
END_FUNCTION_BLOCK