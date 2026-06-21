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
    timerAuto : TON;
    timerGreen : TON;
    timerRed : TON;
    timerYellow : TON;

    currentState : INT := 0;
    autoRunTimer : BOOL;
END_VAR

(* Initialization at the start of each PLC cycle *)
timerGreen(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
timerRed(IN := FALSE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
timerYellow(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);

IF NOT button1 THEN
    (* Manual Mode Logic *)
    IF NOT button2 AND NOT button3 THEN
        greenLight := FALSE;
        redLight := FALSE;
        yellowLight := FALSE;
    ELSIF button2 AND NOT button3 THEN
        greenLight := TRUE;
        timerRed(IN := NOT timerRed.Q, PT := 2000, CYCLE_TIME := CYCLE_TIME);
        redLight := timerRed.Q;
        yellowLight := FALSE;
    ELSIF NOT button2 AND button3 THEN
        redLight := TRUE;
        timerYellow(IN := NOT timerYellow.Q, PT := 1000, CYCLE_TIME := CYCLE_TIME);
        yellowLight := timerYellow.Q;
        greenLight := FALSE;
    ELSIF button2 AND button3 THEN
        yellowLight := TRUE;
        timerGreen(IN := NOT timerGreen.Q, PT := 1000, CYCLE_TIME := CYCLE_TIME);
        greenLight := timerGreen.Q;
        redLight := FALSE;
    END_IF;
ELSE
    (* Automatic Mode Logic *)
    CASE currentState OF
        0:
            greenLight := TRUE;
            redLight := FALSE;
            yellowLight := FALSE;
            timerAuto(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
            IF timerAuto.Q THEN
                currentState := 1;
            END_IF;
        1:
            greenLight := FALSE;
            redLight := TRUE;
            yellowLight := FALSE;
            timerAuto(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
            IF timerAuto.Q THEN
                currentState := 2;
            END_IF;
        2:
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := TRUE;
            timerAuto(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
            IF timerAuto.Q THEN
                currentState := 0;
            END_IF;
    END_CASE;
END_IF;

END_FUNCTION_BLOCK