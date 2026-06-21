START_ST
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
    state : INT := 0;
    prevState : INT := 0;
END_VAR

    (* State Machine Execution *)
    prevState := state;

    CASE state OF
        0: (* STATE 0: CAR_GREEN_PED_RED (Initial/Idle State) *)
            carLightIsGreen := TRUE;
            pedLightIsGreen := FALSE;
            TimeCounter := 0;

            (* Transition: STATE 0 -> STATE 1 on rising edge of button press *)
            IF (pedBtnPress AND NOT buttonPressedBefore) THEN
                state := 1;
            END_IF;

        1: (* STATE 1: CAR_RED_PED_RED_WAIT (Waiting for Pedestrian Green) *)
            carLightIsGreen := FALSE;
            pedLightIsGreen := FALSE;
            TimeCounter := TimeCounter + 1;

            (* Transition: STATE 1 -> STATE 2 when counter >= 10 *)
            IF TimeCounter >= 10 THEN
                state := 2;
            END_IF;

        2: (* STATE 2: CAR_RED_PED_GREEN (Pedestrian Crossing) *)
            carLightIsGreen := FALSE;
            pedLightIsGreen := TRUE;
            TimeCounter := TimeCounter + 1;

            (* Transition: STATE 2 -> STATE 3 when counter >= 40 *)
            IF TimeCounter >= 40 THEN
                state := 3;
            END_IF;

        3: (* STATE 3: CAR_RED_PED_RED_CLEAR (All-Red Clearance) *)
            carLightIsGreen := FALSE;
            pedLightIsGreen := FALSE;
            TimeCounter := TimeCounter + 1;

            (* Transition: STATE 3 -> STATE 0 when counter >= 50 *)
            IF TimeCounter >= 50 THEN
                state := 0;
            END_IF;
    END_CASE;

    (* Update edge detection memory for the button *)
    buttonPressedBefore := pedBtnPress;

END_FUNCTION_BLOCK
END_ST