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
    state : INT;
    buttonPressedBefore : BOOL := FALSE;
    currentBtnState : BOOL;
    prevBtnState : BOOL := FALSE;
END_VAR

BEGIN
    (* --- 3. DECLARE THE NEEDED VARIABLES & EDGE DETECTION --- *)
    
    (* Store current button state for next cycle edge detection *)
    currentBtnState := pedBtnPress;
    
    (* Detect rising edge: Button pressed now but not in previous cycle *)
    IF currentBtnState = TRUE AND prevBtnState = FALSE THEN
        buttonPressedBefore := TRUE;
    ELSE
        buttonPressedBefore := FALSE;
    END_IF;
    
    (* Update previous button state for next cycle *)
    prevBtnState := currentBtnState;

    (* --- 0. DECLARE THE NEEDED STATES & 4. IMPLEMENTATION LOGIC DETAILS --- *)
    
    (* Default initialization for first execution if state is 0 or reset needed *)
    IF state = 0 THEN
        TimeCounter := 0;
    END_IF;

    (* --- STATE MACHINE LOGIC --- *)
    
    CASE state OF
        (* STATE 0: INITIAL / IDLE *)
        (* Description: System is waiting for a button press. Car light is Green, Pedestrian light is Red. Counter is 0. *)
        (* Logic: If PedBtnPress is true and not pressed before, transition to STATE 1. *)
        0:
            carLightIsGreen := TRUE;
            pedLightIsGreen := FALSE;
            TimeCounter := 0; (* Ensure counter is 0 in idle state *)
            
            (* Transition Condition: Button Pressed Edge *)
            IF buttonPressedBefore = TRUE THEN
                state := 1;
            END_IF;

        (* STATE 1: CAR RED / PED GREEN (WAITING) *)
        (* Description: Car light is Red, Pedestrian light is Green. *)
        (* Logic: Increment counter. When counter reaches 10, transition to STATE 2. *)
        1:
            carLightIsGreen := FALSE;
            pedLightIsGreen := TRUE;
            TimeCounter := TimeCounter + 1;
            
            (* Transition Condition: Counter = 10 *)
            IF TimeCounter = 10 THEN
                state := 2;
            END_IF;

        (* STATE 2: CAR RED / PED GREEN (COUNTING) *)
        (* Description: Car light is Red, Pedestrian light is Green. *)
        (* Logic: Increment counter. When counter reaches 40, transition to STATE 3. *)
        2:
            carLightIsGreen := FALSE;
            pedLightIsGreen := TRUE;
            TimeCounter := TimeCounter + 1;
            
            (* Transition Condition: Counter = 40 *)
            IF TimeCounter = 40 THEN
                state := 3;
            END_IF;

        (* STATE 3: CAR RED / PED GREEN (FINAL COUNT) *)
        (* Description: Car light is Red, Pedestrian light is Green. *)
        (* Logic: Increment counter. When counter reaches 50, transition to STATE 0. *)
        3:
            carLightIsGreen := FALSE;
            pedLightIsGreen := TRUE;
            TimeCounter := TimeCounter + 1;
            
            (* Transition Condition: Counter = 50 *)
            IF TimeCounter = 50 THEN
                state := 0;
            END_IF;

        (* STATE 4: CAR GREEN / PED RED (NORMAL FLOW) *)
        (* Description: Car light is Green, Pedestrian light is Red. *)
        (* Logic: Reset counter to 0. If PedBtnPress is true and not pressed before, transition to STATE 1. Otherwise, stay in STATE 4. *)
        4:
            carLightIsGreen := TRUE;
            pedLightIsGreen := FALSE;
            TimeCounter := 0; (* Reset counter as per requirement for Green Car state *)
            
            (* Transition Condition: Button Pressed Edge *)
            IF buttonPressedBefore = TRUE THEN
                state := 1;
            END_IF;
            (* Else: Stay in STATE 4 *)
    END_CASE;

    (* Ensure TimeCounter is always output correctly even if state logic doesn't explicitly set it in all paths *)
    (* Note: In this FSM design, every state sets TimeCounter appropriately, but this acts as a safeguard *)
    IF state = 0 THEN
        TimeCounter := 0;
    ELSIF state = 1 THEN
        TimeCounter := TimeCounter + 1;
    ELSIF state = 2 THEN
        TimeCounter := TimeCounter + 1;
    ELSIF state = 3 THEN
        TimeCounter := TimeCounter + 1;
    ELSIF state = 4 THEN
        TimeCounter := 0;
    END_IF;

END_FUNCTION_BLOCK
END_ST