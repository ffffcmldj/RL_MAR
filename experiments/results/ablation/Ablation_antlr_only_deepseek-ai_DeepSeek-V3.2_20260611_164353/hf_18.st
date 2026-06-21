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
END_VAR

// Main logic
// Edge detection for control button
IF controlButton AND NOT lastControlButton THEN
    // State transition logic on rising edge
    CASE state OF
        1: state := 2; // State 1 -> State 2
        2: state := 3; // State 2 -> State 3
        3: state := 4; // State 3 -> State 4
        4: state := 5; // State 4 -> State 5
        5: state := 1; // State 5 -> State 1
    END_CASE;
END_IF;

// Update last button state
lastControlButton := controlButton;

// State execution logic
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
END_CASE;

END_FUNCTION_BLOCK;