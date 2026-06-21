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

IF button1 = FALSE THEN
timerGreen := NEW TON(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
timerRed := NEW TON(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
timerYellow := NEW TON(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);

IF button2 = FALSE AND button3 = FALSE THEN
greenLight := FALSE;
redLight := FALSE;
yellowLight := FALSE;
ELSIF button2 = TRUE AND button3 = FALSE THEN
greenLight := TRUE;
timerRed := NEW TON(IN := TRUE, PT := 2000, CYCLE_TIME := CYCLE_TIME);
redLight := timerRed.Q;
yellowLight := FALSE;
ELSIF button2 = FALSE AND button3 = TRUE THEN
redLight := TRUE;
timerYellow := NEW TON(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
yellowLight := NOT timerYellow.Q;
greenLight := FALSE;
ELSIF button2 = TRUE AND button3 = TRUE THEN
yellowLight := TRUE;
timerGreen := NEW TON(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);
greenLight := NOT timerGreen.Q;
redLight := FALSE;
END_IF;
ELSE
autoRunTimer := TRUE;
timerAuto := NEW TON(IN := TRUE, PT := 1000, CYCLE_TIME := CYCLE_TIME);

IF timerAuto.Q = TRUE THEN
currentState := currentState + 1;
IF currentState > 2 THEN
currentState := 0;
END_IF;
timerAuto := NEW TON(IN := FALSE, PT := 0, CYCLE_TIME := CYCLE_TIME);
END_IF;

IF currentState = 0 THEN
greenLight := TRUE;
redLight := FALSE;
yellowLight := FALSE;
ELSIF currentState = 1 THEN
greenLight := FALSE;
redLight := TRUE;
yellowLight := FALSE;
ELSIF currentState = 2 THEN
greenLight := FALSE;
redLight := FALSE;
yellowLight := TRUE;
END_IF;
END_IF;
END_FUNCTION_BLOCK