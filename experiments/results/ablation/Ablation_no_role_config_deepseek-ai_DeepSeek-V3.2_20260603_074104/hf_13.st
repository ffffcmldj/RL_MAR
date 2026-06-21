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
    autoRunTimer : BOOL;
    
    (* Internal variables for blinking logic *)
    blinkHalfHz : BOOL;
    blinkOneHzGreen : BOOL;
    blinkOneHzYellow : BOOL;
END_VAR

(* Reset manual timers at start of each cycle *)
timerGreen(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
timerRed(IN := FALSE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
timerYellow(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);

(* Default light states *)
greenLight := FALSE;
redLight := FALSE;
yellowLight := FALSE;

IF NOT button1 THEN (* Manual Mode *)
    (* Reset automatic mode *)
    autoRunTimer := FALSE;
    timerAuto(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    currentState := 0;
    
    (* Manual mode logic *)
    IF NOT button2 AND NOT button3 THEN
        (* Both FALSE: All lights off *)
        greenLight := FALSE;
        redLight := FALSE;
        yellowLight := FALSE;
        
    ELSIF button2 AND NOT button3 THEN
        (* Green ON, Red blinks at 0.5Hz *)
        greenLight := TRUE;
        
        (* Create 0.5Hz blink using timerRed with PT=2000ms *)
        timerRed(IN := TRUE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
        
        (* For 0.5Hz (2000ms period, 1000ms ON, 1000ms OFF):
           Use timerRed.ET to create square wave *)
        IF timerRed.ET < 1000 THEN
            redLight := TRUE;
        ELSE
            redLight := FALSE;
        END_IF;
        
        yellowLight := FALSE;
        
    ELSIF NOT button2 AND button3 THEN
        (* Red ON, Yellow blinks at 1Hz *)
        redLight := TRUE;
        
        (* Create 1Hz blink using timerYellow with PT=1000ms *)
        timerYellow(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
        
        (* For 1Hz (1000ms period, 500ms ON, 500ms OFF):
           Use timerYellow.ET to create square wave *)
        IF timerYellow.ET < 500 THEN
            yellowLight := TRUE;
        ELSE
            yellowLight := FALSE;
        END_IF;
        
        greenLight := FALSE;
        
    ELSIF button2 AND button3 THEN
        (* Yellow ON, Green blinks at 1Hz *)
        yellowLight := TRUE;
        
        (* Create 1Hz blink using timerGreen with PT=1000ms *)
        timerGreen(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
        
        (* For 1Hz (1000ms period, 500ms ON, 500ms OFF):
           Use timerGreen.ET to create square wave *)
        IF timerGreen.ET < 500 THEN
            greenLight := TRUE;
        ELSE
            greenLight := FALSE;
        END_IF;
        
        redLight := FALSE;
    END_IF;
    
ELSE (* Automatic Mode *)
    (* Start automatic timer *)
    autoRunTimer := TRUE;
    timerAuto(IN := autoRunTimer, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    
    (* State machine for automatic mode *)
    CASE currentState OF
        0: (* State 0: Green light ON for 1 second *)
            greenLight := TRUE;
            redLight := FALSE;
            yellowLight := FALSE;
            
            IF timerAuto.Q THEN
                (* Move to next state and reset timer *)
                currentState := 1;
                timerAuto(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
                timerAuto(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
            END_IF;
            
        1: (* State 1: Red light ON for 1 second *)
            greenLight := FALSE;
            redLight := TRUE;
            yellowLight := FALSE;
            
            IF timerAuto.Q THEN
                (* Move to next state and reset timer *)
                currentState := 2;
                timerAuto(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
                timerAuto(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
            END_IF;
            
        2: (* State 2: Yellow light ON for 1 second *)
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := TRUE;
            
            IF timerAuto.Q THEN
                (* Return to State 0 and reset timer *)
                currentState := 0;
                timerAuto(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
                timerAuto(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
            END_IF;
    END_CASE;
END_IF;

END_FUNCTION_BLOCK

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
        (* Rising edge detected, reset timer *)
        elapsedTimeInternal := 0;
    END_IF;
    
    IF elapsedTimeInternal < PT THEN
        (* Timer is running *)
        elapsedTimeInternal := elapsedTimeInternal + CYCLE_TIME;
        Q := FALSE;
    ELSE
        (* Timer has reached preset time *)
        elapsedTimeInternal := PT;
        Q := TRUE;
    END_IF;
    
    ET := elapsedTimeInternal;
ELSE
    (* Timer is not active *)
    Q := FALSE;
    ET := 0;
    elapsedTimeInternal := 0;
END_IF;

IN_PREV := IN;

END_FUNCTION_BLOCK