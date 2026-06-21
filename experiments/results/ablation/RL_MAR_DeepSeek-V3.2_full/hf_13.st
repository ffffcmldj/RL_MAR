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
END_FUNCTION_BLOCK;

FUNCTION_BLOCK LightsControl
VAR_INPUT
    button1 : BOOL;
    button2 : BOOL;
    button3 : BOOL;
    CYCLE_TIME : DINT;
END_VAR
VAR_OUTPUT
    greenLight : BOOL;
    redLight : BOOL;
    yellowLight : BOOL;
END_VAR
VAR
    timerAuto : TON;
    timerGreen : TON;
    timerRed : TON;
    timerYellow : TON;
    currentState : INT := 0;
    autoRunTimer : BOOL;
END_VAR

IF NOT button1 THEN
    timerGreen(IN:=FALSE, PT:=1000, CYCLE_TIME:=CYCLE_TIME);
    timerRed(IN:=FALSE, PT:=1000, CYCLE_TIME:=CYCLE_TIME);
    timerYellow(IN:=FALSE, PT:=500, CYCLE_TIME:=CYCLE_TIME);
    
    IF NOT button2 AND NOT button3 THEN
        greenLight := FALSE;
        redLight := FALSE;
        yellowLight := FALSE;
    ELSIF button2 AND NOT button3 THEN
        greenLight := TRUE;
        timerRed(IN:=TRUE, PT:=1000, CYCLE_TIME:=CYCLE_TIME);
        redLight := timerRed.Q;
        yellowLight := FALSE;
    ELSIF NOT button2 AND button3 THEN
        redLight := TRUE;
        timerYellow(IN:=TRUE, PT:=500, CYCLE_TIME:=CYCLE_TIME);
        yellowLight := NOT timerYellow.Q;
        greenLight := FALSE;
    ELSIF button2 AND button3 THEN
        yellowLight := TRUE;
        timerGreen(IN:=TRUE, PT:=500, CYCLE_TIME:=CYCLE_TIME);
        greenLight := NOT timerGreen.Q;
        redLight := FALSE;
    END_IF;
ELSE
    autoRunTimer := TRUE;
    timerAuto(IN:=autoRunTimer, PT:=1000, CYCLE_TIME:=CYCLE_TIME);
    
    IF timerAuto.Q THEN
        currentState := currentState + 1;
        IF currentState > 2 THEN
            currentState := 0;
        END_IF;
        timerAuto(IN:=FALSE, PT:=1000, CYCLE_TIME:=CYCLE_TIME);
        timerAuto(IN:=TRUE, PT:=1000, CYCLE_TIME:=CYCLE_TIME);
    END_IF;
    
    CASE currentState OF
        0:
            greenLight := TRUE;
            redLight := FALSE;
            yellowLight := FALSE;
        1:
            greenLight := FALSE;
            redLight := TRUE;
            yellowLight := FALSE;
        2:
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := TRUE;
        ELSE
            currentState := 0;
            greenLight := TRUE;
            redLight := FALSE;
            yellowLight := FALSE;
    END_CASE;
END_IF;
END_FUNCTION_BLOCK;