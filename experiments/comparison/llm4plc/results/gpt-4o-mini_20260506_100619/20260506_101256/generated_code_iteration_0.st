ructured-text
START_ST
FUNCTION_BLOCK FB_ColorLightControl
{ S7_Optimized_Access := 'TRUE' }
VAR_INPUT 
    controlButton : BOOL; // Push button for sequence control
END_VAR

VAR_OUTPUT 
    greenLight : BOOL; // Green light control signal
    redLight : BOOL; // Red light control signal
    yellowLight : BOOL; // Yellow light control signal
END_VAR

VAR 
    state : INT := 1; // State machine control variable
    lastControlButton : BOOL := FALSE; // Previous button state
    currentButton : BOOL; // Current button state for edge detection
END_VAR

// Edge Detection Logic
currentButton := controlButton;

// Check for button press condition
IF (currentButton = TRUE) AND (lastControlButton = FALSE) THEN
    // State Sequence Execution
    CASE state OF
        1: // State 1: Green Only
            greenLight := TRUE;
            redLight := FALSE;
            yellowLight := FALSE;
            state := 2; // Transition to State 2
        2: // State 2: Red Only
            greenLight := FALSE;
            redLight := TRUE;
            yellowLight := FALSE;
            state := 3; // Transition to State 3
        3: // State 3: Yellow Only
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := TRUE;
            state := 4; // Transition to State 4
        4: // State 4: All Lights On
            greenLight := TRUE;
            redLight := TRUE;
            yellowLight := TRUE;
            state := 5; // Transition to State 5
        5: // State 5: All Lights Off
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := FALSE;
            state := 1; // Transition back to State 1
    END_CASE;
END_IF;

// Update lastControlButton state at the end of each cycle
lastControlButton := currentButton;

END_FUNCTION_BLOCK
END_ST