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
END_VAR

IF controlButton AND NOT lastControlButton THEN
    CASE state OF
        1:
            greenLight := TRUE;
            redLight := FALSE;
            yellowLight := FALSE;
            state := 2;
        2:
            greenLight := FALSE;
            redLight := TRUE;
            yellowLight := FALSE;
            state := 3;
        3:
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := TRUE;
            state := 4;
        4:
            greenLight := TRUE;
            redLight := TRUE;
            yellowLight := TRUE;
            state := 5;
        5:
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := FALSE;
            state := 1;
        ELSE
            state := 1;
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := FALSE;
    END_CASE;
END_IF;

lastControlButton := controlButton;

END_FUNCTION_BLOCK;