START_ST

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

(* Manual Mode Timer Reset at Start of Cycle *)
IF NOT button1 THEN
    (* Reset all manual timers by calling with IN = FALSE *)
    timerGreen(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    timerRed(IN := FALSE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
    timerYellow(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
END_IF;

(* Main Mode Selection *)
IF button1 THEN (* Automatic Mode *)
    (* Automatic Mode State Machine *)
    autoRunTimer := TRUE;
    timerAuto(IN := autoRunTimer, PT := 1000, CYCLE_TIME := CYCLE_TIME);

    CASE currentState OF
        0: (* State 0: GREEN_ON *)
            greenLight := TRUE;
            redLight := FALSE;
            yellowLight := FALSE;
            IF timerAuto.Q THEN
                currentState := 1;
                (* Reset timer for next state *)
                autoRunTimer := FALSE;
                timerAuto(IN := autoRunTimer, PT := 1000, CYCLE_TIME := CYCLE_TIME);
                autoRunTimer := TRUE;
            END_IF;

        1: (* State 1: RED_ON *)
            greenLight := FALSE;
            redLight := TRUE;
            yellowLight := FALSE;
            IF timerAuto.Q THEN
                currentState := 2;
                (* Reset timer for next state *)
                autoRunTimer := FALSE;
                timerAuto(IN := autoRunTimer, PT := 1000, CYCLE_TIME := CYCLE_TIME);
                autoRunTimer := TRUE;
            END_IF;

        2: (* State 2: YELLOW_ON *)
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := TRUE;
            IF timerAuto.Q THEN
                currentState := 0;
                (* Reset timer for next state *)
                autoRunTimer := FALSE;
                timerAuto(IN := autoRunTimer, PT := 1000, CYCLE_TIME := CYCLE_TIME);
                autoRunTimer := TRUE;
            END_IF;
    END_CASE;

ELSE (* Manual Mode *)
    (* Manual Mode Logic *)
    autoRunTimer := FALSE;
    timerAuto(IN := autoRunTimer, PT := 1000, CYCLE_TIME := CYCLE_TIME);

    IF NOT button2 AND NOT button3 THEN
        (* Both FALSE: All lights OFF *)
        greenLight := FALSE;
        redLight := FALSE;
        yellowLight := FALSE;
    ELSIF button2 AND NOT button3 THEN
        (* button2 TRUE, button3 FALSE: greenLight ON, redLight blinks *)
        greenLight := TRUE;
        timerRed(IN := TRUE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
        redLight := timerRed.Q;
        yellowLight := FALSE;
    ELSIF NOT button2 AND button3 THEN
        (* button2 FALSE, button3 TRUE: redLight ON, yellowLight blinks *)
        redLight := TRUE;
        timerYellow(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
        yellowLight := NOT timerYellow.Q;
        greenLight := FALSE;
    ELSIF button2 AND button3 THEN
        (* Both TRUE: yellowLight ON, greenLight blinks *)
        yellowLight := TRUE;
        timerGreen(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
        greenLight := NOT timerGreen.Q;
        redLight := FALSE;
    END_IF;
END_IF;
END_FUNCTION_BLOCK

END_ST