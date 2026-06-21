FUNCTION_BLOCK RoboticWeldingSystem
VAR_INPUT
    RobotArm1Ready : BOOL; (* Input for robot arm 1 ready status *)
    RobotArm2Ready : BOOL; (* Input for robot arm 2 ready status *)
    WeldingGunReady : BOOL; (* Input for welding gun ready status *)
    StartButton : BOOL; (* Input for start button press *)
    StopButton : BOOL; (* Input for stop button press *)
END_VAR
VAR_OUTPUT
    WeldingTrigger : BOOL; (* Output to trigger welding *)
    WeldingComplete : BOOL; (* Output indicating welding completion *)
END_VAR
VAR
    // Internal state variable: 0=Idle/Ready, 1=Welding Active
    CurrentState : INT;
    
    // Edge detection for StartButton
    StartButtonPrev : BOOL;
    StartButtonRisingEdge : BOOL;
    
    // Timer for welding duration (simplified implementation)
    WeldingTimer : TON;
    WeldingDuration : TIME := T#2S; (* Example welding duration *)
    
    // Internal flag to track if welding was completed normally
    WeldingNormalComplete : BOOL;
END_VAR

// Initialize on first scan
IF NOT WeldingTimer.IN THEN
    CurrentState := 0; // Start in Idle/Ready state
    WeldingTrigger := FALSE;
    WeldingComplete := TRUE;
    StartButtonPrev := FALSE;
    WeldingNormalComplete := FALSE;
END_IF

// Detect rising edge on StartButton
StartButtonRisingEdge := StartButton AND NOT StartButtonPrev;
StartButtonPrev := StartButton;

// Safety Stop has highest priority
IF StopButton THEN
    // Immediate stop - transition to Idle/Ready state
    CurrentState := 0;
    WeldingTrigger := FALSE;
    WeldingComplete := TRUE;
    WeldingTimer.IN := FALSE; // Reset timer
    WeldingNormalComplete := FALSE;
ELSE
    // State machine logic
    CASE CurrentState OF
        0: // Idle/Ready State
            WeldingTrigger := FALSE;
            WeldingComplete := TRUE;
            WeldingTimer.IN := FALSE; // Ensure timer is off
            
            // Check conditions to start welding
            IF RobotArm1Ready AND RobotArm2Ready AND WeldingGunReady 
               AND StartButtonRisingEdge THEN
                CurrentState := 1; // Transition to Welding Active
                WeldingNormalComplete := FALSE;
            END_IF;
            
        1: // Welding Active State
            WeldingTrigger := TRUE;
            WeldingComplete := FALSE;
            
            // Start and monitor welding timer
            WeldingTimer(IN:=TRUE, PT:=WeldingDuration);
            
            // Check if welding is complete
            IF WeldingTimer.Q THEN
                CurrentState := 0; // Transition back to Idle/Ready
                WeldingNormalComplete := TRUE;
                WeldingTimer.IN := FALSE; // Reset timer
            END_IF;
    END_CASE
END_IF

// Update outputs based on state
IF CurrentState = 0 THEN
    WeldingTrigger := FALSE;
    WeldingComplete := TRUE;
ELSIF CurrentState = 1 THEN
    WeldingTrigger := TRUE;
    WeldingComplete := FALSE;
END_IF

// Ensure WeldingComplete is TRUE when not welding or when StopButton was pressed
IF NOT WeldingTrigger OR StopButton THEN
    WeldingComplete := TRUE;
END_IF
END_FUNCTION_BLOCK