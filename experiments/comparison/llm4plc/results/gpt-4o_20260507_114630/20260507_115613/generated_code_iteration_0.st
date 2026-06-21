plaintext
START_ST
FUNCTION_BLOCK CottonCandyMachine
VAR_INPUT
    SugarLevel : REAL; (* Input for sugar level *)
    SpinningSpeed : INT; (* Input for spinning speed *)
END_VAR
VAR_OUTPUT
    SugarFeeder : BOOL; (* Output to control sugar feeding *)
    MotorSpeed : INT; (* Output to control spinning motor speed *)
END_VAR
VAR
    state : INT; (* Current state of the machine *)
    prevState : INT; (* Previous state of the machine *)
END_VAR

(* Initialize the state machine on the first scan *)
IF prevState = 0 THEN
    state := 0; (* Start in IDLE state *)
END_IF

(* State machine logic *)
CASE state OF
    0: (* STATE 0: IDLE *)
        SugarFeeder := FALSE; (* Turn off sugar feeder *)
        MotorSpeed := 0; (* Stop motor *)
        
        (* Transition logic *)
        IF SugarLevel < 10.0 THEN
            state := 1; (* Transition to STATE 1: SUGAR FEEDING *)
        END_IF

    1: (* STATE 1: SUGAR FEEDING *)
        SugarFeeder := TRUE; (* Turn on sugar feeder *)
        MotorSpeed := 0; (* Keep motor stopped *)
        
        (* Transition logic *)
        IF SugarLevel >= 10.0 THEN
            state := 2; (* Transition to STATE 2: MOTOR CONTROL *)
        END_IF

    2: (* STATE 2: MOTOR CONTROL *)
        SugarFeeder := FALSE; (* Turn off sugar feeder *)
        
        (* Set motor speed based on SpinningSpeed input *)
        IF SpinningSpeed > 0 THEN
            MotorSpeed := SpinningSpeed; (* Set motor speed to SpinningSpeed *)
        ELSE
            MotorSpeed := 0; (* Stop motor if SpinningSpeed is 0 or negative *)
        END_IF
        
        (* Transition logic *)
        IF SugarLevel < 10.0 THEN
            state := 1; (* Transition back to STATE 1: SUGAR FEEDING *)
        ELSIF SpinningSpeed <= 0 AND SugarLevel >= 10.0 THEN
            state := 0; (* Transition back to STATE 0: IDLE *)
        END_IF
END_CASE

(* Update prevState to track state transitions *)
prevState := state;

END_FUNCTION_BLOCK
END_ST