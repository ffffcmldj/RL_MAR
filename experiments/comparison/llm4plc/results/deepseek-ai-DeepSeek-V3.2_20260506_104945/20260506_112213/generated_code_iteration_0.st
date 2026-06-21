START_ST
FUNCTION_BLOCK FB_ColorLightControl
{ S7_Optimized_Access := 'TRUE' }
VAR_INPUT
    controlButton : BOOL;
END_VAR

VAR_OUTPUT
    greenLight : BOOL;
    redLight : BOOL;
    yellowLight : BOOL;
END_VAR

VAR
    state : INT := 1;
    lastControlButton : BOOL := FALSE;
    risingEdge : BOOL;
END_VAR

    // Edge detection
    risingEdge := (controlButton = TRUE) AND (lastControlButton = FALSE);

    // State transition on rising edge
    IF risingEdge THEN
        CASE state OF
            1: state := 2;
            2: state := 3;
            3: state := 4;
            4: state := 5;
            5: state := 1;
        END_CASE;
    END_IF;

    // Output logic based on current state
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

    // Update last button state for next cycle
    lastControlButton := controlButton;

END_FUNCTION_BLOCK
END_ST