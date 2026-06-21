START_REASON
The feedback indicates that there was a syntax error in the code where a semicolon was expected instead of the identifier `STATE_INIT`. This error likely occurred due to a missing semicolon after the variable declaration or assignment. To correct this, I will ensure that all statements are properly terminated with semicolons and review the overall structure for any other potential issues.
END_REASON

START_ST
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

// State Definitions
CONST 
    STATE_INIT : INT := 0;
    STATE_MANUAL_WAIT : INT := 1;
    STATE_MANUAL_FORWARD : INT := 2;
    STATE_MANUAL_REVERSE : INT := 3;
    STATE_AUTO_WAIT_A : INT := 4;
    STATE_AUTO_PROCESS_A : INT := 5;
    STATE_AUTO_MOVE_B : INT := 6;
    STATE_AUTO_PROCESS_B : INT := 7;
    STATE_AUTO_MOVE_C : INT := 8;
    STATE_AUTO_PROCESS_C : INT := 9;
    STATE_CYCLE_COMPLETE : INT := 10;
END_CONST

// Initialization
IF State = STATE_INIT THEN
    MotorForward := FALSE;
    MotorReverse := FALSE;
    CompletionLight := FALSE;
    State := STATE_MANUAL_WAIT; // Transition to manual waiting state
END_IF;


// Manual Mode Operation
IF Mode = FALSE THEN
    CASE State OF
        STATE_MANUAL_WAIT:
            IF ForwardButton AND NOT ReverseButton THEN
                State := STATE_MANUAL_FORWARD; // Transition to forward motion
            ELSIF ReverseButton AND NOT ForwardButton THEN
                State := STATE_MANUAL_REVERSE; // Transition to reverse motion
            ELSIF (ForwardButton AND ReverseButton) OR (NOT ForwardButton AND NOT ReverseButton) THEN
                MotorForward := FALSE;
                MotorReverse := FALSE; // Stop both motors
            END_IF;

        STATE_MANUAL_FORWARD:
            MotorForward := TRUE;
            MotorReverse := FALSE; // Set forward motion
            IF NOT ForwardButton THEN
                State := STATE_MANUAL_WAIT; // Return to waiting state
            END_IF;

        STATE_MANUAL_REVERSE:
            MotorForward := FALSE;
            MotorReverse := TRUE; // Set reverse motion
            IF NOT ReverseButton THEN
                State := STATE_MANUAL_WAIT; // Return to waiting state
            END_IF;

    END_CASE;


// Automatic Mode Operation
ELSE
    CASE State OF
        STATE_MANUAL_WAIT:
            State := STATE_AUTO_WAIT_A; // Transition to automatic waiting state

        STATE_AUTO_WAIT_A:
            IF SensorA THEN
                State := STATE_AUTO_PROCESS_A; // Transition to processing at station A
            END_IF;

        STATE_AUTO_PROCESS_A:
            MotorForward := TRUE;
            MotorReverse := FALSE; // Set forward motion
            IF ButtonA THEN
                State := STATE_AUTO_MOVE_B; // Transition to moving to station B
            END_IF;

        STATE_AUTO_MOVE_B:
            MotorForward := FALSE; // Stop motor
            IF SensorB THEN
                State := STATE_AUTO_PROCESS_B; // Transition to processing at station B
            END_IF;

        STATE_AUTO_PROCESS_B:
            MotorForward := TRUE;
            MotorReverse := FALSE; // Set forward motion
            IF ButtonB THEN
                State := STATE_AUTO_MOVE_C; // Transition to moving to station C
            END_IF;

        STATE_AUTO_MOVE_C:
            MotorForward := FALSE; // Stop motor
            IF SensorC THEN
                State := STATE_AUTO_PROCESS_C; // Transition to processing at station C
            END_IF;

        STATE_AUTO_PROCESS_C:
            MotorForward := TRUE;
            MotorReverse := FALSE; // Set forward motion
            IF ButtonC THEN
                CompletionLight := TRUE; // Turn on completion light
                State := STATE_CYCLE_COMPLETE; // Transition to cycle completion
            END_IF;

        STATE_CYCLE_COMPLETE:
            MotorForward := FALSE; // Stop motor
            IF NOT SensorC THEN
                CompletionLight := FALSE; // Turn off completion light
                State := STATE_AUTO_WAIT_A; // Return to waiting state
            END_IF;

    END_CASE;
END_IF;

END_FUNCTION_BLOCK
END_ST