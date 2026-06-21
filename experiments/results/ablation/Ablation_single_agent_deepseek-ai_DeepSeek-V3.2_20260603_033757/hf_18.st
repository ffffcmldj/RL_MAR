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

// Main logic
IF controlButton AND NOT lastControlButton THEN
    // Rising edge detected - execute state transition
    CASE state OF
        1: // State 1: Green Only
            greenLight := TRUE;
            redLight := FALSE;
            yellowLight := FALSE;
            state := 2;
            
        2: // State 2: Red Only
            greenLight := FALSE;
            redLight := TRUE;
            yellowLight := FALSE;
            state := 3;
            
        3: // State 3: Yellow Only
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := TRUE;
            state := 4;
            
        4: // State 4: All Lights On
            greenLight := TRUE;
            redLight := TRUE;
            yellowLight := TRUE;
            state := 5;
            
        5: // State 5: All Lights Off
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := FALSE;
            state := 1;
    END_CASE;
ELSE
    // No rising edge - maintain current light states
    CASE state OF
        1:
            greenLight := TRUE;
            redLight := FALSE;
            yellowLight := FALSE;
            
        2:
            greenLight := FALSE;
            redLight := TRUE;
            yellowLight := FALSE;
            
        3:
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := TRUE;
            
        4:
            greenLight := TRUE;
            redLight := TRUE;
            yellowLight := TRUE;
            
        5:
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := FALSE;
    END_CASE;
END_IF;

// Update last button state for next cycle
lastControlButton := controlButton;

END_FUNCTION_BLOCK