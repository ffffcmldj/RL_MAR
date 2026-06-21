ructured-text
FUNCTION_BLOCK PrecisionEngravingMachine
VAR_INPUT
    DesignSelection : INT;
END_VAR

VAR_OUTPUT
    ZAxisMotor : BOOL;
    EngravingMotor : BOOL;
    EngravingDepth : REAL;
    EngravingSpeed : REAL;
END_VAR

VAR
    state : INT; // THE STATE VARIABLE
    prevState : INT; // THE PREVIOUS STATE VARIABLE
END_VAR

// State Definitions
CONST
    STATE_INITIALIZE : INT := 0;
    STATE_DESIGN_1 : INT := 1;
    STATE_DESIGN_2 : INT := 2;
    STATE_DESIGN_3 : INT := 3;
    STATE_DISABLE : INT := 4;
END_CONST

// State Machine Logic
IF state = STATE_INITIALIZE THEN
    ZAxisMotor := FALSE;
    EngravingMotor := FALSE;
    EngravingDepth := 0.0;
    EngravingSpeed := 0.0;

    IF DesignSelection = 1 THEN
        state := STATE_DESIGN_1;
    ELSIF DesignSelection = 2 THEN
        state := STATE_DESIGN_2;
    ELSIF DesignSelection = 3 THEN
        state := STATE_DESIGN_3;
    ELSE
        state := STATE_DISABLE;
    END_IF

ELSIF state = STATE_DESIGN_1 THEN
    ZAxisMotor := TRUE;
    EngravingMotor := TRUE;
    EngravingDepth := 0.1;
    EngravingSpeed := 10.0;

    IF DesignSelection < 1 OR DesignSelection > 3 THEN
        state := STATE_DISABLE;
    END_IF

ELSIF state = STATE_DESIGN_2 THEN
    ZAxisMotor := TRUE;
    EngravingMotor := TRUE;
    EngravingDepth := 0.2;
    EngravingSpeed := 8.0;

    IF DesignSelection < 1 OR DesignSelection > 3 THEN
        state := STATE_DISABLE;
    END_IF

ELSIF state = STATE_DESIGN_3 THEN
    ZAxisMotor := TRUE;
    EngravingMotor := TRUE;
    EngravingDepth := 0.15;
    EngravingSpeed := 12.0;

    IF DesignSelection < 1 OR DesignSelection > 3 THEN
        state := STATE_DISABLE;
    END_IF

ELSIF state = STATE_DISABLE THEN
    ZAxisMotor := FALSE;
    EngravingMotor := FALSE;
    EngravingDepth := 0.0;
    EngravingSpeed := 0.0;

    // Reset to initial state if DesignSelection is valid
    IF DesignSelection = 1 THEN
        state := STATE_DESIGN_1;
    ELSIF DesignSelection = 2 THEN
        state := STATE_DESIGN_2;
    ELSIF DesignSelection = 3 THEN
        state := STATE_DESIGN_3;
    ELSE
        state := STATE_INITIALIZE;
    END_IF
END_IF

END_FUNCTION_BLOCK