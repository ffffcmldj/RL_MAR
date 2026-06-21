pascal
START_ST

FUNCTION_BLOCK TON
VAR_INPUT
    IN : BOOL; (* Timer enable input *)
    PT : DINT; (* Preset time in milliseconds *)
    CYCLE_TIME : DINT; (* Time elapsed in the current PLC cycle (in ms) *)
END_VAR
VAR_OUTPUT
    Q : BOOL; (* Timer output *)
    ET : DINT; (* Elapsed time *)
END_VAR
VAR
    elapsedTimeInternal : DINT := 0; (* Internal elapsed time *)
    IN_PREV : BOOL := FALSE; (* Previous state of IN *)
END_VAR

IF IN THEN
    IF NOT IN_PREV THEN
        elapsedTimeInternal := 0; (* Reset elapsed time on rising edge *)
    END_IF;

    IF elapsedTimeInternal < PT THEN
        elapsedTimeInternal := elapsedTimeInternal + CYCLE_TIME; (* Accumulate time *)
        Q := FALSE;
    ELSE
        elapsedTimeInternal := PT; (* Cap elapsed time at PT *)
        Q := TRUE;
    END_IF;

    ET := elapsedTimeInternal; (* Update elapsed time output *)
ELSE
    Q := FALSE;
    ET := 0;
    elapsedTimeInternal := 0; (* Reset elapsed time when IN is FALSE *)
END_IF;

IN_PREV := IN; (* Update previous state of IN *)

END_FUNCTION_BLOCK


FUNCTION_BLOCK LightsControl
VAR_INPUT
    button1 : BOOL; (* Automatic/Manual Mode Select *)
    button2 : BOOL; (* Manual Control/Green Light Request *)
    button3 : BOOL; (* Manual Control/Red Light Request *)
    CYCLE_TIME : DINT; (* Time elapsed in current PLC cycle (in ms) *)
END_VAR
VAR_OUTPUT
    greenLight : BOOL; (* Green light state *)
    redLight : BOOL; (* Red light state *)
    yellowLight : BOOL; (* Yellow light state *)
END_VAR
VAR
    timerAuto : TON; (* Timer for automatic mode state transitions *)
    timerGreen : TON; (* Timer for green light blinking in manual mode *)
    timerRed : TON; (* Timer for red light blinking in manual mode *)
    timerYellow : TON; (* Timer for yellow light blinking in manual mode *)
    currentState : INT := 0; (* Current state of the FSM *)
    autoRunTimer : BOOL; (* Internal flag for automatic mode timer *)
END_VAR

(* Reset manual mode timers at the start of each cycle *)
timerGreen(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
timerRed(IN := FALSE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
timerYellow(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME);

IF button1 THEN
    (* Automatic Mode *)
    timerAuto(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);

    IF timerAuto.Q THEN
        timerAuto(IN := FALSE, PT := 1000, CYCLE_TIME := CYCLE_TIME); (* Reset timer *)
        currentState := (currentState + 1) MOD 3; (* Cycle through states 0 -> 1 -> 2 -> 0 *)
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

ELSE
    (* Manual Mode *)
    IF NOT button2 AND NOT button3 THEN
        (* State 3: All lights OFF *)
        currentState := 3;
        greenLight := FALSE;
        redLight := FALSE;
        yellowLight := FALSE;
    ELSIF button2 AND NOT button3 THEN
        (* State 4: Green light ON, Red light blinking *)
        currentState := 4;
        timerRed(IN := TRUE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
        greenLight := TRUE;
        redLight := timerRed.Q;
        yellowLight := FALSE;
    ELSIF NOT button2 AND button3 THEN
        (* State 5: Red light ON, Yellow light blinking *)
        currentState := 5;
        timerYellow(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
        greenLight := FALSE;
        redLight := TRUE;
        yellowLight := NOT timerYellow.Q;
    ELSIF button2 AND button3 THEN
        (* State 6: Yellow light ON, Green light blinking *)
        currentState := 6;
        timerGreen(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
        greenLight := NOT timerGreen.Q;
        redLight := FALSE;
        yellowLight := TRUE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK

END_ST