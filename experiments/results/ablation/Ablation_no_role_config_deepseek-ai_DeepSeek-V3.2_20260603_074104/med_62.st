FUNCTION_BLOCK FB_PedestrianTrafficLight
VAR_INPUT
    pedBtnPress : BOOL;
END_VAR
VAR_OUTPUT
    carLightIsGreen : BOOL;
    pedLightIsGreen : BOOL;
    counter : INT;
END_VAR
VAR
    buttonPressedBefore : BOOL := FALSE;
    state : INT := 1; // 1: Normal, 2: Wait for ped green, 3: Ped green, 4: Wait for car green
END_VAR

// State machine logic
CASE state OF
    1: // Normal state - Car green, Ped red
        carLightIsGreen := TRUE;
        pedLightIsGreen := FALSE;
        counter := 0;
        
        // Detect rising edge of button press
        IF pedBtnPress AND NOT buttonPressedBefore THEN
            state := 2;
        END_IF;
        
    2: // Car red, waiting for pedestrian green
        carLightIsGreen := FALSE;
        pedLightIsGreen := FALSE;
        counter := counter + 1;
        
        IF counter >= 10 THEN
            state := 3;
        END_IF;
        
    3: // Car red, pedestrian green
        carLightIsGreen := FALSE;
        pedLightIsGreen := TRUE;
        counter := counter + 1;
        
        IF counter >= 40 THEN
            state := 4;
        END_IF;
        
    4: // Car red, waiting for car green
        carLightIsGreen := FALSE;
        pedLightIsGreen := FALSE;
        counter := counter + 1;
        
        IF counter >= 50 THEN
            state := 1;
        END_IF;
END_CASE;

// Update button press tracking
buttonPressedBefore := pedBtnPress;

END_FUNCTION_BLOCK