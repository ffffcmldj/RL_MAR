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

// Main logic
IF State = 0 THEN
    // Initialization state
    MotorForward := FALSE;
    MotorReverse := FALSE;
    CompletionLight := FALSE;
    State := 1;
END_IF;

IF NOT Mode THEN
    // Manual Mode Operation
    IF ForwardButton AND NOT ReverseButton THEN
        // Forward Motion
        MotorForward := TRUE;
        MotorReverse := FALSE;
    ELSIF ReverseButton AND NOT ForwardButton THEN
        // Reverse Motion
        MotorForward := FALSE;
        MotorReverse := TRUE;
    ELSE
        // Stop Condition (both pressed or neither pressed)
        MotorForward := FALSE;
        MotorReverse := FALSE;
    END_IF;
    
    // Reset state to 1 when switching to manual mode
    State := 1;
    CompletionLight := FALSE;
ELSE
    // Automatic Mode Operation
    CASE State OF
        1: // Waiting at Station A
            MotorForward := FALSE;
            MotorReverse := FALSE;
            IF SensorA THEN
                State := 2;
            END_IF;
            
        2: // Processing at Station A
            MotorForward := FALSE;
            MotorReverse := FALSE;
            IF ButtonA THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
                State := 3;
            END_IF;
            
        3: // Moving to Station B
            // Keep MotorForward TRUE from previous state
            MotorReverse := FALSE;
            IF SensorB THEN
                MotorForward := FALSE;
                State := 4;
            END_IF;
            
        4: // Processing at Station B
            MotorForward := FALSE;
            MotorReverse := FALSE;
            IF ButtonB THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
                State := 5;
            END_IF;
            
        5: // Moving to Station C
            // Keep MotorForward TRUE from previous state
            MotorReverse := FALSE;
            IF SensorC THEN
                MotorForward := FALSE;
                State := 6;
            END_IF;
            
        6: // Processing at Station C
            MotorForward := FALSE;
            MotorReverse := FALSE;
            IF ButtonC THEN
                CompletionLight := TRUE;
                State := 7;
            END_IF;
            
        7: // Cycle Completion
            MotorForward := FALSE;
            MotorReverse := FALSE;
            IF NOT SensorC THEN
                CompletionLight := FALSE;
                State := 1;
            END_IF;
    END_CASE;
END_IF;

END_FUNCTION_BLOCK