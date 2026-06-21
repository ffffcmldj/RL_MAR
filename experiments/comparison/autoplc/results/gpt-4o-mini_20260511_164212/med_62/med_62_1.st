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

    // Initialize outputs
    carLightIsGreen := FALSE;
    pedLightIsGreen := FALSE;
    TimeCounter := 0;

    // Check for button press event
    IF pedBtnPress AND NOT buttonPressedBefore THEN
        carLightIsGreen := FALSE; // Turn car light red
        buttonPressedBefore := TRUE; // Mark button as pressed
    END_IF

    // Manage counter based on car light state
    IF carLightIsGreen THEN
        TimeCounter := 0; // Reset counter if car light is green
    ELSE
        TimeCounter := TimeCounter + 1; // Increment counter if car light is red
    END_IF

    // Control pedestrian light based on counter value
    IF TimeCounter = 10 THEN
        pedLightIsGreen := TRUE; // Turn pedestrian light green
        carLightIsGreen := FALSE; // Ensure car light is red
    ELSIF TimeCounter = 40 THEN
        pedLightIsGreen := FALSE; // Turn pedestrian light red
    ELSIF TimeCounter = 50 THEN
        carLightIsGreen := TRUE; // Turn car light green
        pedLightIsGreen := FALSE; // Ensure pedestrian light is red
    END_IF

    // Reset button pressed state if button is not pressed
    IF NOT pedBtnPress THEN
        buttonPressedBefore := FALSE; // Allow for new button press
    END_IF
END_FUNCTION_BLOCK