FUNCTION_BLOCK TON
VAR_INPUT
    IN : BOOL;
    PT : DINT;
    CYCLE_TIME : DINT;
END_VAR
VAR_OUTPUT
    Q : BOOL;
    ET : DINT;
END_VAR
VAR
    elapsedTimeInternal : DINT := 0;
    IN_PREV : BOOL := FALSE;
END_VAR

IF IN THEN
    IF NOT IN_PREV THEN
        elapsedTimeInternal := 0;
    END_IF;

    IF elapsedTimeInternal < PT THEN
        elapsedTimeInternal := elapsedTimeInternal + CYCLE_TIME;
        Q := FALSE;
    ELSE
        elapsedTimeInternal := PT;
        Q := TRUE;
    END_IF;

    ET := elapsedTimeInternal;
ELSE
    Q := FALSE;
    ET := 0;
    elapsedTimeInternal := 0;
END_IF;

IN_PREV := IN;
END_FUNCTION_BLOCK

FUNCTION_BLOCK LightsControl
VAR_INPUT
    button1 : BOOL; (* Automatic (TRUE) / Manual (FALSE) Mode Select *)
    button2 : BOOL; (* Manual Control / Green Light Request *)
    button3 : BOOL; (* Manual Control / Red Light Request *)
    CYCLE_TIME : DINT; (* Time elapsed in the current PLC cycle (in ms) *)
END_VAR
VAR_OUTPUT
    greenLight : BOOL; (* Green indicator light state *)
    redLight : BOOL; (* Red indicator light state *)
    yellowLight : BOOL; (* Yellow indicator light state *)
END_VAR
VAR
    (* Timers for control *)
    timerAuto : TON;
    timerGreen : TON;
    timerRed : TON;
    timerYellow : TON;
    currentState : INT := 0;
    autoRunTimer : BOOL;
END_VAR

(* Initialize timer cycle times *)
timerAuto.CYCLE_TIME := CYCLE_TIME;
timerGreen.CYCLE_TIME := CYCLE_TIME;
timerRed.CYCLE_TIME := CYCLE_TIME;
timerYellow.CYCLE_TIME := CYCLE_TIME;

(* Manual Mode (button1 = FALSE) *)
IF NOT button1 THEN
    (* Reset automatic mode state and timer *)
    currentState := 0;
    autoRunTimer := FALSE;
    timerAuto.IN := FALSE;
    
    (* CRITICAL: Reset all manual timers at start of every PLC cycle *)
    timerGreen.IN := FALSE;
    timerRed.IN := FALSE;
    timerYellow.IN := FALSE;
    
    (* Execute manual timers with reset state *)
    timerGreen(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    timerRed(IN := FALSE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
    timerYellow(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    
    (* Manual mode logic based on button combinations *)
    IF NOT button2 AND NOT button3 THEN
        (* Both FALSE: All lights off *)
        greenLight := FALSE;
        redLight := FALSE;
        yellowLight := FALSE;
        
    ELSIF button2 AND NOT button3 THEN
        (* button2 TRUE, button3 FALSE *)
        greenLight := TRUE;
        timerRed.IN := TRUE;
        timerRed(IN := TRUE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
        redLight := timerRed.Q; (* Blinks at 0.5Hz *)
        yellowLight := FALSE;
        
    ELSIF NOT button2 AND button3 THEN
        (* button2 FALSE, button3 TRUE *)
        redLight := TRUE;
        timerYellow.IN := TRUE;
        timerYellow(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
        yellowLight := NOT timerYellow.Q; (* Blinks at 1Hz *)
        greenLight := FALSE;
        
    ELSIF button2 AND button3 THEN
        (* Both TRUE *)
        yellowLight := TRUE;
        timerGreen.IN := TRUE;
        timerGreen(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
        greenLight := NOT timerGreen.Q; (* Blinks at 1Hz *)
        redLight := FALSE;
    END_IF;
    
(* Automatic Mode (button1 = TRUE) *)
ELSE
    (* CRITICAL: Reset all manual timers when entering automatic mode *)
    timerGreen.IN := FALSE;
    timerRed.IN := FALSE;
    timerYellow.IN := FALSE;
    
    (* Execute manual timers with reset state *)
    timerGreen(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    timerRed(IN := FALSE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
    timerYellow(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    
    (* Automatic mode state machine *)
    autoRunTimer := TRUE;
    timerAuto.IN := autoRunTimer;
    timerAuto(IN := autoRunTimer, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    
    (* State transition logic *)
    IF timerAuto.Q THEN
        currentState := currentState + 1;
        IF currentState > 2 THEN
            currentState := 0;
        END_IF;
    END_IF;
    
    (* State output logic *)
    CASE currentState OF
        0: (* State 0: Green light on for 1 second *)
            greenLight := TRUE;
            redLight := FALSE;
            yellowLight := FALSE;
            
        1: (* State 1: Red light on for 1 second *)
            greenLight := FALSE;
            redLight := TRUE;
            yellowLight := FALSE;
            
        2: (* State 2: Yellow light on for 1 second *)
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := TRUE;
    END_CASE;
END_IF;

END_FUNCTION_BLOCK