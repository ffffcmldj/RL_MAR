FUNCTION_BLOCK FB_PedestrianTrafficLight
VAR_INPUT
    pedBtnPress : BOOL;
END_VAR
VAR_OUTPUT
    carLightIsGreen : BOOL;
    pedLightIsGreen : BOOL;
    TimeCounter : INT;
END_VAR
VAR
    buttonPressedBefore : BOOL := FALSE;
    tempCarLight : BOOL;
    tempPedLight : BOOL;
END_VAR

    buttonPressedBefore := pedBtnPress;

    IF pedBtnPress = TRUE AND buttonPressedBefore = FALSE THEN
        tempCarLight := FALSE;
        tempPedLight := TRUE;
        TimeCounter := 0;
    ELSE
        tempCarLight := carLightIsGreen;
        tempPedLight := pedLightIsGreen;
    END_IF;

    IF tempCarLight = FALSE THEN
        TimeCounter := TimeCounter + 1;
    ELSE
        TimeCounter := 0;
    END_IF;

    IF TimeCounter < 10 THEN
        tempCarLight := FALSE;
        tempPedLight := TRUE;
    ELSIF TimeCounter = 10 THEN
        tempCarLight := FALSE;
        tempPedLight := FALSE;
    ELSIF TimeCounter = 50 THEN
        tempCarLight := TRUE;
        tempPedLight := FALSE;
        TimeCounter := 0;
    ELSE
        IF TimeCounter > 50 THEN
            tempCarLight := TRUE;
            tempPedLight := FALSE;
            TimeCounter := 0;
        END_IF;
    END_IF;

    carLightIsGreen := tempCarLight;
    pedLightIsGreen := tempPedLight;

END_FUNCTION_BLOCK