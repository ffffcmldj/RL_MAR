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
    button1 : BOOL; (* Button 1: Automatic/Manual Mode Select *)
    button2 : BOOL; (* Button 2: Manual Control/Green Light Req *)
    button3 : BOOL; (* Button 3: Manual Control/Red Light Req *)
    CYCLE_TIME : DINT; (* Time elapsed in current cycle (in ms) *)
END_VAR
VAR_OUTPUT
    greenLight : BOOL; (* Green light *)
    redLight : BOOL; (* Red light *)
    yellowLight : BOOL; (* Yellow light *)
END_VAR
VAR
    (* Timers for control *)
    timerAuto : TON;
    timerGreen : TON;
    timerRed : TON;
    timerYellow : TON;
    
    currentState : INT := 0;
    autoRunTimer : BOOL := TRUE;
    
    (* Internal variables for blinking control *)
    blinkToggleRed : BOOL := FALSE;
    blinkToggleYellow : BOOL := FALSE;
    blinkToggleGreen : BOOL := FALSE;
    prevTimerRedQ : BOOL := FALSE;
    prevTimerYellowQ : BOOL := FALSE;
    prevTimerGreenQ : BOOL := FALSE;
END_VAR

(* Reset all outputs initially *)
greenLight := FALSE;
redLight := FALSE;
yellowLight := FALSE;

IF button1 THEN (* Automatic Mode *)
    (* Reset manual mode timers *)
    timerGreen(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
    timerRed(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
    timerYellow(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
    
    (* Reset blinking toggle variables *)
    blinkToggleRed := FALSE;
    blinkToggleYellow := FALSE;
    blinkToggleGreen := FALSE;
    
    (* Automatic mode state machine *)
    timerAuto(IN := autoRunTimer, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    
    CASE currentState OF
        0: (* State 0: Green light ON for 1 second *)
            greenLight := TRUE;
            redLight := FALSE;
            yellowLight := FALSE;
            
            IF timerAuto.Q THEN
                currentState := 1;
                timerAuto(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
            END_IF;
            
        1: (* State 1: Red light ON for 1 second *)
            greenLight := FALSE;
            redLight := TRUE;
            yellowLight := FALSE;
            
            IF timerAuto.Q THEN
                currentState := 2;
                timerAuto(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
            END_IF;
            
        2: (* State 2: Yellow light ON for 1 second *)
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := TRUE;
            
            IF timerAuto.Q THEN
                currentState := 0;
                timerAuto(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
            END_IF;
    END_CASE;
    
    (* Restart timer for next cycle *)
    IF NOT timerAuto.IN THEN
        timerAuto(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    END_IF;
    
ELSE (* Manual Mode *)
    (* Reset automatic mode timer *)
    timerAuto(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
    
    (* Reset automatic mode state *)
    currentState := 0;
    
    (* Manual mode logic based on button combinations *)
    IF NOT button2 AND NOT button3 THEN
        (* Both FALSE: All lights off *)
        greenLight := FALSE;
        redLight := FALSE;
        yellowLight := FALSE;
        
        (* Reset all timers and blinking states *)
        timerGreen(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
        timerRed(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
        timerYellow(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
        blinkToggleRed := FALSE;
        blinkToggleYellow := FALSE;
        blinkToggleGreen := FALSE;
        
    ELSIF button2 AND NOT button3 THEN
        (* button2 TRUE, button3 FALSE: Green light ON, Red light blinking at 0.5Hz *)
        greenLight := TRUE;
        yellowLight := FALSE;
        
        (* Red light blinking logic *)
        timerRed(IN := TRUE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
        
        (* Detect rising edge of timer output to toggle blink *)
        IF timerRed.Q AND NOT prevTimerRedQ THEN
            blinkToggleRed := NOT blinkToggleRed;
        END_IF;
        prevTimerRedQ := timerRed.Q;
        
        (* Red light blinks at 0.5Hz using timer Q directly *)
        redLight := blinkToggleRed;
        
        (* Reset other timers *)
        timerGreen(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
        timerYellow(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
        blinkToggleYellow := FALSE;
        blinkToggleGreen := FALSE;
        
    ELSIF NOT button2 AND button3 THEN
        (* button2 FALSE, button3 TRUE: Red light ON, Yellow light blinking at 1Hz *)
        redLight := TRUE;
        greenLight := FALSE;
        
        (* Yellow light blinking logic *)
        timerYellow(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
        
        (* Detect rising edge of timer output to toggle blink *)
        IF timerYellow.Q AND NOT prevTimerYellowQ THEN
            blinkToggleYellow := NOT blinkToggleYellow;
        END_IF;
        prevTimerYellowQ := timerYellow.Q;
        
        (* Yellow light blinks at 1Hz using NOT timer Q *)
        yellowLight := blinkToggleYellow;
        
        (* Reset other timers *)
        timerGreen(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
        timerRed(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
        blinkToggleRed := FALSE;
        blinkToggleGreen := FALSE;
        
    ELSIF button2 AND button3 THEN
        (* Both TRUE: Yellow light ON, Green light blinking at 1Hz *)
        yellowLight := TRUE;
        redLight := FALSE;
        
        (* Green light blinking logic *)
        timerGreen(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
        
        (* Detect rising edge of timer output to toggle blink *)
        IF timerGreen.Q AND NOT prevTimerGreenQ THEN
            blinkToggleGreen := NOT blinkToggleGreen;
        END_IF;
        prevTimerGreenQ := timerGreen.Q;
        
        (* Green light blinks at 1Hz using NOT timer Q *)
        greenLight := blinkToggleGreen;
        
        (* Reset other timers *)
        timerRed(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
        timerYellow(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
        blinkToggleRed := FALSE;
        blinkToggleYellow := FALSE;
    END_IF;
END_IF;
END_FUNCTION_BLOCK