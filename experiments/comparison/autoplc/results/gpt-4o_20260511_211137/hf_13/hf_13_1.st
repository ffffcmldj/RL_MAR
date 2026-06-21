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
END_VAR

(* Reset manual mode timers at the start of each cycle *)
timerGreen.IN := FALSE;
timerRed.IN := FALSE;
timerYellow.IN := FALSE;

IF NOT button1 THEN
    (* Manual Mode Logic *)
    IF NOT button2 AND NOT button3 THEN
        (* State 0: All lights off *)
        greenLight := FALSE;
        redLight := FALSE;
        yellowLight := FALSE;
    ELSIF button2 AND NOT button3 THEN
        (* State 1: Green light ON, Red light blinks at 0.5Hz *)
        greenLight := TRUE;
        timerRed.IN := TRUE;
        timerRed.PT := 2000;
        timerRed.CYCLE_TIME := CYCLE_TIME;
        redLight := timerRed.Q;
        yellowLight := FALSE;
    ELSIF NOT button2 AND button3 THEN
        (* State 2: Red light ON, Yellow light blinks at 1Hz *)
        redLight := TRUE;
        timerYellow.IN := TRUE;
        timerYellow.PT := 1000;
        timerYellow.CYCLE_TIME := CYCLE_TIME;
        yellowLight := NOT timerYellow.Q;
        greenLight := FALSE;
    ELSE
        (* State 3: Yellow light ON, Green light blinks at 1Hz *)
        yellowLight := TRUE;
        timerGreen.IN := TRUE;
        timerGreen.PT := 1000;
        timerGreen.CYCLE_TIME := CYCLE_TIME;
        greenLight := NOT timerGreen.Q;
        redLight := FALSE;
    END_IF;
ELSE
    (* Automatic Mode Logic *)
    timerAuto.IN := TRUE;
    timerAuto.PT := 1000;
    timerAuto.CYCLE_TIME := CYCLE_TIME;

    IF timerAuto.Q THEN
        currentState := (currentState + 1) MOD 3;
        timerAuto.IN := FALSE; (* Reset the timer for the next state *)
    END_IF;

    CASE currentState OF
        0: (* State 0: Green light ON *)
            greenLight := TRUE;
            redLight := FALSE;
            yellowLight := FALSE;
        1: (* State 1: Red light ON *)
            greenLight := FALSE;
            redLight := TRUE;
            yellowLight := FALSE;
        2: (* State 2: Yellow light ON *)
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := TRUE;
    END_CASE;
END_IF;
END_FUNCTION_BLOCK