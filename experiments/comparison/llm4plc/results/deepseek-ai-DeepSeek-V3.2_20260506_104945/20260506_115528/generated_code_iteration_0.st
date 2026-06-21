START_ST
FUNCTION_BLOCK PrecisionEngravingMachine
VAR_INPUT
    DesignSelection : INT;
    EngravingDepth : REAL;
    EngravingSpeed : REAL;
END_VAR

VAR_OUTPUT
    ZAxisMotor : BOOL;
    EngravingMotor : BOOL;
END_VAR

VAR
    CalculatedDepth : REAL;
    CalculatedSpeed : REAL;
    state : INT;
    prevState : INT;
END_VAR

(* Finite State Machine Execution *)
prevState := state;

CASE DesignSelection OF
    1: state := 1; (* ACTIVE_DESIGN_1 *)
    2: state := 2; (* ACTIVE_DESIGN_2 *)
    3: state := 3; (* ACTIVE_DESIGN_3 *)
ELSE
    state := 4; (* ERROR *)
END_CASE;

(* State Output Logic *)
CASE state OF
    0: (* IDLE *)
        ZAxisMotor := FALSE;
        EngravingMotor := FALSE;
        CalculatedDepth := 0.0;
        CalculatedSpeed := 0.0;
    1: (* ACTIVE_DESIGN_1 *)
        ZAxisMotor := TRUE;
        EngravingMotor := TRUE;
        CalculatedDepth := 0.1;
        CalculatedSpeed := 10.0;
    2: (* ACTIVE_DESIGN_2 *)
        ZAxisMotor := TRUE;
        EngravingMotor := TRUE;
        CalculatedDepth := 0.2;
        CalculatedSpeed := 8.0;
    3: (* ACTIVE_DESIGN_3 *)
        ZAxisMotor := TRUE;
        EngravingMotor := TRUE;
        CalculatedDepth := 0.15;
        CalculatedSpeed := 12.0;
    4: (* ERROR *)
        ZAxisMotor := FALSE;
        EngravingMotor := FALSE;
        CalculatedDepth := 0.0;
        CalculatedSpeed := 0.0;
END_CASE;

END_FUNCTION_BLOCK
END_ST