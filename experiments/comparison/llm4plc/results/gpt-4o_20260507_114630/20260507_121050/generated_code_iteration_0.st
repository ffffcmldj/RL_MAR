plaintext
START_ST
FUNCTION_BLOCK FB_PedestrianTrafficLight
VAR_INPUT
    pedBtnPress : BOOL; // Input variable for pedestrian button press
END_VAR
VAR_OUTPUT
    carLightIsGreen : BOOL; // Output variable indicating if the car light is green
    pedLightIsGreen : BOOL; // Output variable indicating if the pedestrian light is green
    TimeCounter : INT; // Counter to track the timer for light changes
END_VAR
VAR
    state : INT := 0; // The current state of the system
    prevState : INT := 0; // The previous state of the system
    buttonPressedBefore : BOOL := FALSE; // Tracks if the button was pressed in the previous cycle
END_VAR

// State Machine Logic
CASE state OF
    // STATE 0: IDLE
    0:
        carLightIsGreen := TRUE;
        pedLightIsGreen := FALSE;
        TimeCounter := 0;
        
        // Transition to STATE 1 if pedestrian button is pressed
        IF pedBtnPress = TRUE AND buttonPressedBefore = FALSE THEN
            state := 1;
            buttonPressedBefore := TRUE;
        END_IF;

    // STATE 1: CAR_LIGHT_RED
    1:
        carLightIsGreen := FALSE;
        pedLightIsGreen := FALSE;
        
        // Increment TimeCounter
        TimeCounter := TimeCounter + 1;
        
        // Transition to STATE 2 if TimeCounter reaches 10
        IF TimeCounter = 10 THEN
            state := 2;
        END_IF;

    // STATE 2: PED_LIGHT_GREEN
    2:
        carLightIsGreen := FALSE;
        pedLightIsGreen := TRUE;
        
        // Increment TimeCounter
        TimeCounter := TimeCounter + 1;
        
        // Transition to STATE 3 if TimeCounter reaches 40
        IF TimeCounter = 40 THEN
            state := 3;
        END_IF;

    // STATE 3: PED_LIGHT_RED
    3:
        carLightIsGreen := FALSE;
        pedLightIsGreen := FALSE;
        
        // Increment TimeCounter
        TimeCounter := TimeCounter + 1;
        
        // Transition to STATE 4 if TimeCounter reaches 50
        IF TimeCounter = 50 THEN
            state := 4;
        END_IF;

    // STATE 4: CAR_LIGHT_GREEN
    4:
        carLightIsGreen := TRUE;
        pedLightIsGreen := FALSE;
        TimeCounter := 0;
        
        // Reset buttonPressedBefore and transition to STATE 0
        buttonPressedBefore := FALSE;
        state := 0;

END_CASE;
END_FUNCTION_BLOCK
END_ST