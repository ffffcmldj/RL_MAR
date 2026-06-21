(* Custom TON Timer Function Block for Single-Cycle Execution Model *)
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

(* Main Lights Control Function Block *)
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
END_VAR

(* Reset manual timers at start of every PLC cycle as required *)
timerGreen.IN := FALSE;
timerGreen.PT := 1000;
timerGreen.CYCLE_TIME := CYCLE_TIME;

timerRed.IN := FALSE;
timerRed.PT := 2000;
timerRed.CYCLE_TIME := CYCLE_TIME;

timerYellow.IN := FALSE;
timerYellow.PT := 1000;
timerYellow.CYCLE_TIME := CYCLE_TIME;

(* Main mode selection *)
IF button1 THEN
    (* Automatic Mode *)
    timerAuto.IN := TRUE;
    timerAuto.PT := 1000;
    timerAuto.CYCLE_TIME := CYCLE_TIME;
    timerAuto();
    
    (* State machine logic *)
    IF timerAuto.Q THEN
        currentState := currentState + 1;
        IF currentState >= 3 THEN
            currentState := 0;
        END_IF;
    END_IF;
    
    (* Set outputs based on current state *)
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
ELSE
    (* Manual Mode *)
    timerAuto.IN := FALSE;
    
    (* Evaluate button combinations *)
    IF NOT button2 AND NOT button3 THEN
        (* Both FALSE: All lights off *)
        greenLight := FALSE;
        redLight := FALSE;
        yellowLight := FALSE;
        
    ELSIF button2 AND NOT button3 THEN
        (* button2 TRUE, button3 FALSE *)
        greenLight := TRUE;
        timerRed.IN := TRUE;
        timerRed();
        redLight := timerRed.Q; (* Blinks at 0.5Hz *)
        yellowLight := FALSE;
        
    ELSIF NOT button2 AND button3 THEN
        (* button2 FALSE, button3 TRUE *)
        greenLight := FALSE;
        redLight := TRUE;
        timerYellow.IN := TRUE;
        timerYellow();
        yellowLight := NOT timerYellow.Q; (* Blinks at 1Hz *)
        
    ELSIF button2 AND button3 THEN
        (* Both TRUE *)
        timerGreen.IN := TRUE;
        timerGreen();
        greenLight := NOT timerGreen.Q; (* Blinks at 1Hz *)
        redLight := FALSE;
        yellowLight := TRUE;
    END_IF;
END_IF;
END_FUNCTION_BLOCK