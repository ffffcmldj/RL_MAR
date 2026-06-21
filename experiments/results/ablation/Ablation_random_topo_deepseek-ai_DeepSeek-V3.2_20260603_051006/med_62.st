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
    CurrentState : INT := 0;
    NextState : INT := 0;
    pedBtnEdge : R_TRIG;
END_VAR

// Edge detection for button press
pedBtnEdge(CLK := pedBtnPress);

// State machine execution
CASE CurrentState OF
    0: // STATE_CAR_GREEN_IDLE
        // Actions executed in this state
        carLightIsGreen := TRUE;
        pedLightIsGreen := FALSE;
        TimeCounter := 0;
        buttonPressedBefore := pedBtnPress;

        // Transition logic from this state
        IF pedBtnEdge.Q AND NOT buttonPressedBefore THEN
            NextState := 1;
        ELSE
            NextState := 0;
        END_IF;

    1: // STATE_CAR_RED_COUNTING
        // Actions executed in this state
        carLightIsGreen := FALSE;
        pedLightIsGreen := FALSE;
        TimeCounter := TimeCounter + 1;

        // Transition logic from this state
        IF TimeCounter >= 10 AND TimeCounter < 40 THEN
            NextState := 2;
        ELSIF TimeCounter >= 40 AND TimeCounter < 50 THEN
            NextState := 3;
        ELSIF TimeCounter >= 50 THEN
            NextState := 0;
        ELSE
            NextState := 1;
        END_IF;

    2: // STATE_PED_GREEN_COUNTING
        // Actions executed in this state
        carLightIsGreen := FALSE;
        pedLightIsGreen := TRUE;
        TimeCounter := TimeCounter + 1;

        // Transition logic from this state
        IF TimeCounter >= 40 AND TimeCounter < 50 THEN
            NextState := 3;
        ELSIF TimeCounter >= 50 THEN
            NextState := 0;
        ELSE
            NextState := 2;
        END_IF;

    3: // STATE_PED_RED_COUNTING
        // Actions executed in this state
        carLightIsGreen := FALSE;
        pedLightIsGreen := FALSE;
        TimeCounter := TimeCounter + 1;

        // Transition logic from this state
        IF TimeCounter >= 50 THEN
            NextState := 0;
        ELSE
            NextState := 3;
        END_IF;
END_CASE;

// State transition
CurrentState := NextState;

END_FUNCTION_BLOCK