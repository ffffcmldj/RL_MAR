FUNCTION_BLOCK FB_ColorLightControl
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
    END_VAR

    // Main logic for the traffic light sequence control system
    IF (controlButton = TRUE) AND (lastControlButton = FALSE) THEN
        // Rising edge detected, proceed with state transition
        CASE state OF
            1: // State 1: Green Only
                greenLight := TRUE;
                redLight := FALSE;
                yellowLight := FALSE;
                state := 2; // Transition to next state
            2: // State 2: Red Only
                greenLight := FALSE;
                redLight := TRUE;
                yellowLight := FALSE;
                state := 3; // Transition to next state
            3: // State 3: Yellow Only
                greenLight := FALSE;
                redLight := FALSE;
                yellowLight := TRUE;
                state := 4; // Transition to next state
            4: // State 4: All Lights On
                greenLight := TRUE;
                redLight := TRUE;
                yellowLight := TRUE;
                state := 5; // Transition to next state
            5: // State 5: All Lights Off
                greenLight := FALSE;
                redLight := FALSE;
                yellowLight := FALSE;
                state := 1; // Transition back to first state
        END_CASE;
    END_IF;

    // Update lastControlButton state for edge detection
    lastControlButton := controlButton;
END_FUNCTION_BLOCK