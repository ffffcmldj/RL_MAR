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
    currentState : INT := 0; // 0: CarGreen, 1: CarRed_Waiting, 2: PedGreen, 3: PedRed_Waiting
END_VAR

CASE currentState OF
    0: // State 0: Car Green
        carLightIsGreen := TRUE;
        pedLightIsGreen := FALSE;
        TimeCounter := 0;
        
        // Check for button press transition
        IF (pedBtnPress AND NOT buttonPressedBefore) THEN
            currentState := 1;
            buttonPressedBefore := TRUE;
        ELSIF (pedBtnPress = FALSE) THEN
            buttonPressedBefore := FALSE;
        END_IF;

    1: // State 1: Car Red, Waiting for Pedestrian Green
        carLightIsGreen := FALSE;
        pedLightIsGreen := FALSE;
        TimeCounter := TimeCounter + 1;
        
        IF TimeCounter >= 10 THEN
            currentState := 2;
        END_IF;
        
        // Update button memory
        IF (pedBtnPress = FALSE) THEN
            buttonPressedBefore := FALSE;
        END_IF;

    2: // State 2: Pedestrian Green
        carLightIsGreen := FALSE;
        pedLightIsGreen := TRUE;
        TimeCounter := TimeCounter + 1;
        
        IF TimeCounter >= 40 THEN
            currentState := 3;
        END_IF;
        
        // Update button memory
        IF (pedBtnPress = FALSE) THEN
            buttonPressedBefore := FALSE;
        END_IF;

    3: // State 3: Pedestrian Red, Waiting for Car Green
        carLightIsGreen := FALSE;
        pedLightIsGreen := FALSE;
        TimeCounter := TimeCounter + 1;
        
        IF TimeCounter >= 50 THEN
            currentState := 0;
        END_IF;
        
        // Update button memory
        IF (pedBtnPress = FALSE) THEN
            buttonPressedBefore := FALSE;
        END_IF;
END_CASE;

END_FUNCTION_BLOCK