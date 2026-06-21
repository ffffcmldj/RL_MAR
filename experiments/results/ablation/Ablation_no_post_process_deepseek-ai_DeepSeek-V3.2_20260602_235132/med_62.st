(*
FUNCTION_BLOCK: FB_PedestrianTrafficLight
DESCRIPTION: Pedestrian traffic light control system with state machine logic.
INPUTS:
  - pedBtnPress: Pedestrian button press signal (rising edge detection)
OUTPUTS:
  - carLightIsGreen: Car traffic light green status
  - pedLightIsGreen: Pedestrian light green status
  - TimeCounter: Current timer value for state transitions
STATES:
  1: IDLE - Car green, pedestrian red, waiting for button press
  2: CAR_RED - Car red, pedestrian red, counting to pedestrian green
  3: PED_GREEN - Car red, pedestrian green, counting to pedestrian red
  4: PED_RED - Car red, pedestrian red, counting to car green
*)

FUNCTION_BLOCK FB_PedestrianTrafficLight
VAR_INPUT
    pedBtnPress : BOOL; (* Pedestrian button input *)
END_VAR

VAR_OUTPUT
    carLightIsGreen : BOOL; (* Car light status *)
    pedLightIsGreen : BOOL; (* Pedestrian light status *)
    TimeCounter : INT; (* Current counter value *)
END_VAR

VAR
    buttonPressedBefore : BOOL := FALSE; (* Rising edge detection *)
    currentState : INT := 1; (* Current state (1-4) *)
    nextState : INT := 1; (* Next state for transition *)
    pedBtnPressRisingEdge : BOOL; (* Rising edge detection internal *)
END_VAR

(* Rising edge detection for pedestrian button *)
pedBtnPressRisingEdge := pedBtnPress AND NOT buttonPressedBefore;
buttonPressedBefore := pedBtnPress;

(* Main state machine logic *)
CASE currentState OF
    1: (* IDLE: Car green, pedestrian red *)
        carLightIsGreen := TRUE;
        pedLightIsGreen := FALSE;
        TimeCounter := 0;
        
        IF pedBtnPressRisingEdge THEN
            nextState := 2;
        ELSE
            nextState := 1;
        END_IF;
        
    2: (* CAR_RED: Car red, pedestrian red, counting to 10 *)
        carLightIsGreen := FALSE;
        pedLightIsGreen := FALSE;
        TimeCounter := TimeCounter + 1;
        
        IF TimeCounter >= 10 THEN
            nextState := 3;
        ELSE
            nextState := 2;
        END_IF;
        
    3: (* PED_GREEN: Car red, pedestrian green, counting to 40 *)
        carLightIsGreen := FALSE;
        pedLightIsGreen := TRUE;
        TimeCounter := TimeCounter + 1;
        
        IF TimeCounter >= 40 THEN
            nextState := 4;
        ELSE
            nextState := 3;
        END_IF;
        
    4: (* PED_RED: Car red, pedestrian red, counting to 50 *)
        carLightIsGreen := FALSE;
        pedLightIsGreen := FALSE;
        TimeCounter := TimeCounter + 1;
        
        IF TimeCounter >= 50 THEN
            nextState := 1;
        ELSE
            nextState := 4;
        END_IF;
        
END_CASE;

(* State transition *)
currentState := nextState;

END_FUNCTION_BLOCK;