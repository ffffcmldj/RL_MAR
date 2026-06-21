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
    END_VAR

    // Initialization of the system
    IF NOT buttonPressedBefore THEN
        carLightIsGreen := TRUE;
        pedLightIsGreen := FALSE;
        TimeCounter := 0;
    END_IF

    // Button Press Detection
    IF pedBtnPress AND NOT buttonPressedBefore THEN
        buttonPressedBefore := TRUE;
        carLightIsGreen := FALSE;
    END_IF

    // State Management
    IF NOT carLightIsGreen THEN
        // Increment the counter when car light is red
        TimeCounter := TimeCounter + 1;

        // Transition to Pedestrian Light Green State
        IF TimeCounter = 10 THEN
            pedLightIsGreen := TRUE;
        END_IF

        // Transition to Pedestrian Light Red State
        IF TimeCounter = 40 THEN
            pedLightIsGreen := FALSE;
        END_IF

        // Transition to Car Light Green State
        IF TimeCounter = 50 THEN
            carLightIsGreen := TRUE;
            TimeCounter := 0;
            buttonPressedBefore := FALSE;
        END_IF
    ELSE
        // Reset the counter when car light is green
        TimeCounter := 0;
    END_IF
END_FUNCTION_BLOCK