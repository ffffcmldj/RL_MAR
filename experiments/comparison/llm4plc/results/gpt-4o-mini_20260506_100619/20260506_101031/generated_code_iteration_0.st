ructured-text
START_ST
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

(* State Definitions *)
CONST
    STATE_0 : INT := 0; (* MANUAL MODE - BOTH BUTTONS OFF *)
    STATE_1 : INT := 1; (* MANUAL MODE - GREEN LIGHT ON, RED LIGHT BLINKING *)
    STATE_2 : INT := 2; (* MANUAL MODE - RED LIGHT ON, YELLOW LIGHT BLINKING *)
    STATE_3 : INT := 3; (* MANUAL MODE - BOTH BUTTONS ON, YELLOW LIGHT ON, GREEN LIGHT BLINKING *)
    STATE_4 : INT := 4; (* AUTOMATIC MODE - GREEN LIGHT ON *)
    STATE_5 : INT := 5; (* AUTOMATIC MODE - RED LIGHT ON *)
    STATE_6 : INT := 6; (* AUTOMATIC MODE - YELLOW LIGHT ON *)
END_CONST

(* Main Logic *)
IF NOT button1 THEN
    (* Manual Mode Logic *)
    timerGreen(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    timerRed(IN := FALSE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
    timerYellow(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    
    CASE currentState OF
        STATE_0:
            IF button2 AND NOT button3 THEN
                currentState := STATE_1;
            ELSIF NOT button2 AND button3 THEN
                currentState := STATE_2;
            ELSIF button2 AND button3 THEN
                currentState := STATE_3;
            END_IF;
        
        STATE_1:
            greenLight := TRUE;
            redLight := timerRed.Q;
            yellowLight := FALSE;
            IF NOT button2 AND NOT button3 THEN
                currentState := STATE_0;
            END_IF;

        STATE_2:
            greenLight := FALSE;
            redLight := TRUE;
            yellowLight := NOT timerYellow.Q;
            IF NOT button2 AND NOT button3 THEN
                currentState := STATE_0;
            END_IF;

        STATE_3:
            greenLight := NOT timerGreen.Q;
            redLight := FALSE;
            yellowLight := TRUE;
            IF NOT button2 AND NOT button3 THEN
                currentState := STATE_0;
            END_IF;

    END_CASE;

ELSE
    (* Automatic Mode Logic *)
    timerAuto(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
    
    CASE currentState OF
        STATE_4:
            greenLight := TRUE;
            redLight := FALSE;
            yellowLight := FALSE;
            IF timerAuto.Q THEN
                currentState := STATE_5;
            END_IF;

        STATE_5:
            greenLight := FALSE;
            redLight := TRUE;
            yellowLight := FALSE;
            IF timerAuto.Q THEN
                currentState := STATE_6;
            END_IF;

        STATE_6:
            greenLight := FALSE;
            redLight := FALSE;
            yellowLight := TRUE;
            IF timerAuto.Q THEN
                currentState := STATE_4;
            END_IF;

    END_CASE;
END_IF;

END_FUNCTION_BLOCK

FUNCTION_BLOCK TON
VAR_INPUT
    IN : BOOL; (* Input for timer *)
    PT : DINT; (* Preset time for timer *)
    CYCLE_TIME : DINT; (* Time elapsed in current cycle (in ms) *)
END_VAR

VAR_OUTPUT
    Q : BOOL; (* Timer output *)
    ET : DINT; (* Elapsed time *)
END_VAR

VAR
    elapsedTimeInternal : DINT := 0; (* Internal elapsed time *)
    IN_PREV : BOOL := FALSE; (* Previous input state *)
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
END_ST