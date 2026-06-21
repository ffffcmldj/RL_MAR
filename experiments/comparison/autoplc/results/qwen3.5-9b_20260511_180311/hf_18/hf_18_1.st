FUNCTION_BLOCK FB_ColorLightControl
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
        edgeDetected : BOOL;
    END_VAR

    edgeDetected := (controlButton = TRUE) AND (lastControlButton = FALSE);

    IF edgeDetected THEN
        state := state + 1;
        IF state > 5 THEN
            state := 1;
        END_IF;
    END_IF;

    lastControlButton := controlButton;

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

END_FUNCTION_BLOCK