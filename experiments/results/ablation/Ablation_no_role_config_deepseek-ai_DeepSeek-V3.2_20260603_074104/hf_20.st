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

// Main logic
CASE State OF
    0: // Initialization
        MotorForward := FALSE;
        MotorReverse := FALSE;
        CompletionLight := FALSE;
        State := 1;
    
    1: // Mode selection and manual control / Automatic State 1
        IF NOT Mode THEN // Manual Mode
            // Forward Motion
            IF ForwardButton AND NOT ReverseButton THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
            // Reverse Motion
            ELSIF ReverseButton AND NOT ForwardButton THEN
                MotorForward := FALSE;
                MotorReverse := TRUE;
            // Stop Condition (both pressed or neither pressed)
            ELSE
                MotorForward := FALSE;
                MotorReverse := FALSE;
            END_IF;
            CompletionLight := FALSE; // Light off in manual mode
        ELSE // Automatic Mode - State 1: Waiting at Station A
            MotorForward := FALSE;
            MotorReverse := FALSE;
            CompletionLight := FALSE;
            IF SensorA THEN
                State := 2; // Transition to Processing at Station A
            END_IF;
        END_IF;
    
    2: // Automatic Mode - State 2: Processing at Station A
        IF NOT Mode THEN
            State := 1; // Return to manual control if mode changes
        ELSE
            MotorForward := FALSE;
            MotorReverse := FALSE;
            IF ButtonA THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
                State := 3; // Transition to Moving to Station B
            END_IF;
        END_IF;
    
    3: // Automatic Mode - State 3: Moving to Station B
        IF NOT Mode THEN
            State := 1;
        ELSE
            MotorReverse := FALSE; // Safety: ensure reverse is off
            IF SensorB THEN
                MotorForward := FALSE;
                State := 4; // Transition to Processing at Station B
            END_IF;
        END_IF;
    
    4: // Automatic Mode - State 4: Processing at Station B
        IF NOT Mode THEN
            State := 1;
        ELSE
            MotorForward := FALSE;
            MotorReverse := FALSE;
            IF ButtonB THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
                State := 5; // Transition to Moving to Station C
            END_IF;
        END_IF;
    
    5: // Automatic Mode - State 5: Moving to Station C
        IF NOT Mode THEN
            State := 1;
        ELSE
            MotorReverse := FALSE; // Safety: ensure reverse is off
            IF SensorC THEN
                MotorForward := FALSE;
                State := 6; // Transition to Processing at Station C
            END_IF;
        END_IF;
    
    6: // Automatic Mode - State 6: Processing at Station C
        IF NOT Mode THEN
            State := 1;
            CompletionLight := FALSE;
        ELSE
            MotorForward := FALSE;
            MotorReverse := FALSE;
            IF ButtonC THEN
                CompletionLight := TRUE;
                State := 7; // Transition to Cycle Completion
            END_IF;
        END_IF;
    
    7: // Automatic Mode - State 7: Cycle Completion
        IF NOT Mode THEN
            State := 1;
            CompletionLight := FALSE;
        ELSE
            IF NOT SensorC THEN // Product removal detected
                CompletionLight := FALSE;
                State := 1; // Return to State 1 for next cycle
            END_IF;
        END_IF;
    
    ELSE
        State := 0; // Fallback to initialization for invalid states
END_CASE;

END_FUNCTION_BLOCK