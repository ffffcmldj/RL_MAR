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
    CYCLE_TIME : DINT; (* MODIFIED: Time elapsed in current cycle (in ms) *)
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
END_VAR

(* Reset all manual timers at the start of every PLC cycle *)
timerGreen(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
timerRed(IN := FALSE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
timerYellow(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);

(* Initialize outputs *)
greenLight := FALSE;
redLight := FALSE;
yellowLight := FALSE;

IF button1 THEN (* Automatic Mode *)
    (* Start auto timer *)
    timerAuto(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    
    (* State machine implementation *)
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
    
    (* State transition when timer expires *)
    IF timerAuto.Q THEN
        currentState := (currentState + 1) MOD 3;
    END_IF;
    
ELSE (* Manual Mode *)
    (* Reset auto timer in manual mode *)
    timerAuto(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    
    (* Manual mode logic based on button combinations *)
    IF NOT button2 AND NOT button3 THEN
        (* Both FALSE: All lights off *)
        greenLight := FALSE;
        redLight := FALSE;
        yellowLight := FALSE;
        
    ELSIF button2 AND NOT button3 THEN
        (* button2 TRUE, button3 FALSE: Green ON, Red blinking at 0.5Hz *)
        greenLight := TRUE;
        
        (* Start red timer with PT=2000ms *)
        timerRed(IN := TRUE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
        redLight := timerRed.Q; (* Blinking at 0.5Hz *)
        
        yellowLight := FALSE;
        
    ELSIF NOT button2 AND button3 THEN
        (* button2 FALSE, button3 TRUE: Red ON, Yellow blinking at 1Hz *)
        redLight := TRUE;
        
        (* Start yellow timer with PT=1000ms *)
        timerYellow(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
        yellowLight := NOT timerYellow.Q; (* Blinking at 1Hz *)
        
        greenLight := FALSE;
        
    ELSIF button2 AND button3 THEN
        (* Both TRUE: Yellow ON, Green blinking at 1Hz *)
        yellowLight := TRUE;
        
        (* Start green timer with PT=1000ms *)
        timerGreen(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
        greenLight := NOT timerGreen.Q; (* Blinking at 1Hz *)
        
        redLight := FALSE;
    END_IF;
END_IF;
END_FUNCTION_BLOCK