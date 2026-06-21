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
    autoRunTimer : BOOL;
    
    (* Internal variables for manual mode *)
    manualGreenActive : BOOL;
    manualRedActive : BOOL;
    manualYellowActive : BOOL;
END_VAR

(* Reset manual timers at start of every cycle as required *)
timerGreen(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
timerRed(IN := FALSE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
timerYellow(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);

(* Determine manual mode activation *)
manualGreenActive := button2 AND NOT button3;
manualRedActive := button2 AND NOT button3;
manualYellowActive := NOT button2 AND button3;

(* Automatic Mode *)
IF button1 THEN
    autoRunTimer := TRUE;
    timerAuto(IN := autoRunTimer, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    
    CASE currentState OF
        0: (* State 0: Green light on for 1 second *)
            greenLight := TRUE;
            redLight := FALSE;
            yellowLight := FALSE;
            IF timerAuto.Q THEN
                currentState := 1;
                timerAuto.IN := FALSE; (* Reset timer *)
            END_IF;
            
        1: (* State 1: Red light on for 1 second *)
            greenLight := FALSE;
            redLight := TRUE;
            yellowLight := FALSE;
            IF timerAuto.Q THEN
                currentState := 2;
                timerAuto.IN := FALSE; (* Reset timer *)
            END_IF;
            
        2: (* State 2: Yellow light on for 1 second *)
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := TRUE;
            IF timerAuto.Q THEN
                currentState := 0;
                timerAuto.IN := FALSE; (* Reset timer *)
            END_IF;
    END_CASE;
    
(* Manual Mode *)
ELSE
    autoRunTimer := FALSE;
    timerAuto.IN := FALSE;
    currentState := 0;
    
    (* Activate timers based on button combinations *)
    IF manualGreenActive THEN
        timerGreen(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
        timerRed(IN := TRUE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
    ELSIF manualYellowActive THEN
        timerYellow(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    ELSIF button2 AND button3 THEN
        timerGreen(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    END_IF;
    
    (* Manual mode logic *)
    IF NOT button2 AND NOT button3 THEN
        (* Both FALSE: All lights off *)
        greenLight := FALSE;
        redLight := FALSE;
        yellowLight := FALSE;
        
    ELSIF button2 AND NOT button3 THEN
        (* button2 TRUE, button3 FALSE *)
        greenLight := TRUE;
        redLight := timerRed.Q; (* Blinks at 0.5Hz (2000ms period) *)
        yellowLight := FALSE;
        
    ELSIF NOT button2 AND button3 THEN
        (* button2 FALSE, button3 TRUE *)
        greenLight := FALSE;
        redLight := TRUE;
        yellowLight := NOT timerYellow.Q; (* Blinks at 1Hz (1000ms period) *)
        
    ELSIF button2 AND button3 THEN
        (* Both TRUE *)
        greenLight := NOT timerGreen.Q; (* Blinks at 1Hz (1000ms period) *)
        redLight := FALSE;
        yellowLight := TRUE;
    END_IF;
END_IF;
END_FUNCTION_BLOCK