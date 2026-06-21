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
    internalCounter : INT := 0;
END_VAR

// Main control logic
IF carLightIsGreen THEN
    // Car priority state
    internalCounter := 0;
    
    // Rising edge detection for pedestrian button
    IF pedBtnPress AND NOT buttonPressedBefore THEN
        carLightIsGreen := FALSE;
        pedLightIsGreen := FALSE;
        buttonPressedBefore := TRUE;
    END_IF;
    
    // Update button memory
    IF NOT pedBtnPress THEN
        buttonPressedBefore := FALSE;
    END_IF;
ELSE
    // Car light is red - pedestrian crossing state
    internalCounter := internalCounter + 1;
    
    // Control pedestrian light based on counter
    IF internalCounter >= 10 AND internalCounter < 40 THEN
        pedLightIsGreen := TRUE;
    ELSE
        pedLightIsGreen := FALSE;
    END_IF;
    
    // Return to car priority state when counter reaches 50
    IF internalCounter >= 50 THEN
        carLightIsGreen := TRUE;
        internalCounter := 0;
        buttonPressedBefore := FALSE;
    END_IF;
END_IF;

// Update output counter
TimeCounter := internalCounter;

END_FUNCTION_BLOCK