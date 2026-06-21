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

// Edge detection for button press
IF controlButton AND NOT lastControlButton THEN
    // State transition logic
    state := state + 1;
    IF state > 5 THEN
        state := 1;
    END_IF;
END_IF;

// State output logic
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
        
    ELSE // Default case for safety
        greenLight := FALSE;
        redLight := FALSE;
        yellowLight := FALSE;
        state := 1;
END_CASE;

// Store current button state for next cycle
lastControlButton := controlButton;

END_FUNCTION_BLOCK