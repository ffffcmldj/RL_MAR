plaintext
START_ST
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
    state : INT := 1; // State machine control variable (initially set to state 1)
    lastControlButton : BOOL := FALSE; // Stores the previous state of the controlButton for edge detection
END_VAR

// Main logic
IF (controlButton = TRUE AND lastControlButton = FALSE) THEN
    // Rising edge detected, advance to the next state
    state := state + 1;
    IF state > 5 THEN
        state := 1; // Wrap around to state 1 after state 5
    END_IF;
END_IF;

// State machine logic
CASE state OF
    1: // State 1: Green Only
        greenLight := TRUE;
        redLight := FALSE;
        yellowLight := FALSE;
    2: // State 2: Red Only
        greenLight := FALSE;
        redLight := TRUE;
        yellowLight := FALSE;
    3: // State 3: Yellow Only
        greenLight := FALSE;
        redLight := FALSE;
        yellowLight := TRUE;
    4: // State 4: All Lights On
        greenLight := TRUE;
        redLight := TRUE;
        yellowLight := TRUE;
    5: // State 5: All Lights Off
        greenLight := FALSE;
        redLight := FALSE;
        yellowLight := FALSE;
    ELSE
        // Default case (should not occur)
        greenLight := FALSE;
        redLight := FALSE;
        yellowLight := FALSE;
END_CASE;

// Update lastControlButton state
lastControlButton := controlButton;

END_FUNCTION_BLOCK
END_ST