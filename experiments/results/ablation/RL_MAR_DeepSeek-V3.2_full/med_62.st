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
    currentState : INT := 0;
    nextState : INT := 0;
END_VAR

CASE currentState OF
    0:
        carLightIsGreen := TRUE;
        pedLightIsGreen := FALSE;
        TimeCounter := 0;
        
        IF pedBtnPress AND NOT buttonPressedBefore THEN
            buttonPressedBefore := TRUE;
            nextState := 1;
        ELSE
            nextState := 0;
        END_IF;
        
    1:
        carLightIsGreen := FALSE;
        pedLightIsGreen := FALSE;
        TimeCounter := TimeCounter + 1;
        
        IF TimeCounter >= 10 THEN
            nextState := 2;
        ELSE
            nextState := 1;
        END_IF;
        
    2:
        carLightIsGreen := FALSE;
        pedLightIsGreen := TRUE;
        TimeCounter := TimeCounter + 1;
        
        IF TimeCounter >= 40 THEN
            nextState := 3;
        ELSE
            nextState := 2;
        END_IF;
        
    3:
        carLightIsGreen := FALSE;
        pedLightIsGreen := FALSE;
        TimeCounter := TimeCounter + 1;
        
        IF TimeCounter >= 50 THEN
            buttonPressedBefore := FALSE;
            nextState := 0;
        ELSE
            nextState := 3;
        END_IF;
        
    ELSE
        nextState := 0;
END_CASE;

currentState := nextState;

END_FUNCTION_BLOCK;