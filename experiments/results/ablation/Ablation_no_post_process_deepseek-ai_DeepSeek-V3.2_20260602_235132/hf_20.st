FUNCTION_BLOCK FB_ProductionLineControl
VAR_INPUT
    Mode : BOOL;            // Manual/Auto mode selection
    ForwardButton : BOOL;   // Forward rotation button
    ReverseButton : BOOL;   // Reverse rotation button
    SensorA : BOOL;         // Sensor A input
    SensorB : BOOL;         // Sensor B input
    SensorC : BOOL;         // Sensor C input
    ButtonA : BOOL;         // Button A input
    ButtonB : BOOL;         // Button B input
    ButtonC : BOOL;         // Button C input
END_VAR

VAR_OUTPUT
    MotorForward : BOOL;    // Motor forward output
    MotorReverse : BOOL;    // Motor reverse output
    CompletionLight : BOOL; // Process completion indicator
END_VAR

VAR
    State : INT := 0;       // State machine current state
END_VAR

// Main execution logic
CASE State OF
    0: // Initialization state
        MotorForward := FALSE;
        MotorReverse := FALSE;
        CompletionLight := FALSE;
        State := 1;
        
    1: // State 1: Waiting at Station A
        IF NOT Mode THEN // Manual Mode
            // Manual motor control with mutual exclusion
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
        ELSE // Automatic Mode
            // Safety: Ensure reverse motor is off in auto mode
            MotorReverse := FALSE;
            MotorForward := FALSE;
            
            // Wait for SensorA activation
            IF SensorA THEN
                State := 2;
            END_IF;
        END_IF;
        
    2: // State 2: Processing at Station A
        IF NOT Mode THEN // Manual Mode
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
        ELSE // Automatic Mode
            MotorReverse := FALSE;
            MotorForward := FALSE;
            
            // Wait for ButtonA press
            IF ButtonA THEN
                MotorForward := TRUE;
                State := 3;
            END_IF;
        END_IF;
        
    3: // State 3: Moving to Station B
        IF NOT Mode THEN // Manual Mode
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
        ELSE // Automatic Mode
            MotorReverse := FALSE;
            
            // Wait for SensorB activation
            IF SensorB THEN
                MotorForward := FALSE;
                State := 4;
            END_IF;
        END_IF;
        
    4: // State 4: Processing at Station B
        IF NOT Mode THEN // Manual Mode
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
        ELSE // Automatic Mode
            MotorReverse := FALSE;
            MotorForward := FALSE;
            
            // Wait for ButtonB press
            IF ButtonB THEN
                MotorForward := TRUE;
                State := 5;
            END_IF;
        END_IF;
        
    5: // State 5: Moving to Station C
        IF NOT Mode THEN // Manual Mode
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
        ELSE // Automatic Mode
            MotorReverse := FALSE;
            
            // Wait for SensorC activation
            IF SensorC THEN
                MotorForward := FALSE;
                State := 6;
            END_IF;
        END_IF;
        
    6: // State 6: Processing at Station C
        IF NOT Mode THEN // Manual Mode
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
        ELSE // Automatic Mode
            MotorReverse := FALSE;
            MotorForward := FALSE;
            
            // Wait for ButtonC press
            IF ButtonC THEN
                CompletionLight := TRUE;
                State := 7;
            END_IF;
        END_IF;
        
    7: // State 7: Cycle Completion
        IF NOT Mode THEN // Manual Mode
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
        ELSE // Automatic Mode
            MotorReverse := FALSE;
            MotorForward := FALSE;
            
            // Wait for product removal (SensorC deactivation)
            IF NOT SensorC THEN
                CompletionLight := FALSE;
                State := 1;
            END_IF;
        END_IF;
        
END_CASE;

END_FUNCTION_BLOCK;