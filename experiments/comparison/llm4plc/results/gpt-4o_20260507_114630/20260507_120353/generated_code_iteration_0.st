plaintext
START_ST
FUNCTION_BLOCK PrecisionEngravingMachine
VAR_INPUT
    DesignSelection : INT; // Input for the selected design
    EngravingDepth : REAL; // Input for engraving depth
    EngravingSpeed : REAL; // Input for engraving speed
END_VAR

VAR_OUTPUT
    ZAxisMotor : BOOL; // Output to control the Z-axis motor
    EngravingMotor : BOOL; // Output to control the engraving motor
END_VAR

VAR
    state : INT; // Current state of the system
    prevState : INT; // Previous state of the system to detect state changes
    CalculatedDepth : REAL; // Internal variable to store the calculated engraving depth
    CalculatedSpeed : REAL; // Internal variable to store the calculated engraving speed
END_VAR

// State Definitions
// STATE 0: IDLE
// STATE 1: CONFIGURE DESIGN PARAMETERS
// STATE 2: ACTIVATE MOTORS
// STATE 3: INVALID DESIGN

// Initialization
IF (state = 0) AND (prevState = 0) THEN
    // Set initial state to IDLE
    state := 0;
    prevState := 0;
    ZAxisMotor := FALSE;
    EngravingMotor := FALSE;
    CalculatedDepth := 0.0;
    CalculatedSpeed := 0.0;
ENDIF;

// State Machine Logic
CASE state OF
    // STATE 0: IDLE
    0: 
        ZAxisMotor := FALSE;
        EngravingMotor := FALSE;
        CalculatedDepth := 0.0;
        CalculatedSpeed := 0.0;

        // Transition to STATE 1 if a valid design is selected
        IF DesignSelection IN [1, 2, 3] THEN
            state := 1;
        END_IF;

    // STATE 1: CONFIGURE DESIGN PARAMETERS
    1:
        ZAxisMotor := FALSE;
        EngravingMotor := FALSE;

        // Configure engraving parameters based on design selection
        CASE DesignSelection OF
            1: 
                CalculatedDepth := 0.1;
                CalculatedSpeed := 10.0;
            2: 
                CalculatedDepth := 0.2;
                CalculatedSpeed := 8.0;
            3: 
                CalculatedDepth := 0.15;
                CalculatedSpeed := 12.0;
        ELSE
            // Transition to STATE 3 if invalid design is selected
            state := 3;
        END_CASE;

        // Transition to STATE 2 if a valid design is selected
        IF DesignSelection IN [1, 2, 3] THEN
            state := 2;
        END_IF;

    // STATE 2: ACTIVATE MOTORS
    2:
        ZAxisMotor := TRUE;
        EngravingMotor := TRUE;

        // Retain the calculated depth and speed
        EngravingDepth := CalculatedDepth;
        EngravingSpeed := CalculatedSpeed;

        // Transition to STATE 1 if design changes to another valid design
        IF (DesignSelection IN [1, 2, 3]) AND (DesignSelection <> prevState) THEN
            state := 1;
        END_IF;

        // Transition to STATE 3 if design changes to an invalid design
        IF DesignSelection NOT IN [1, 2, 3] THEN
            state := 3;
        END_IF;

    // STATE 3: INVALID DESIGN
    3:
        ZAxisMotor := FALSE;
        EngravingMotor := FALSE;
        CalculatedDepth := 0.0;
        CalculatedSpeed := 0.0;

        // Transition to STATE 1 if a valid design is selected
        IF DesignSelection IN [1, 2, 3] THEN
            state := 1;
        END_IF;
END_CASE;

// Update previous state
prevState := state;

END_FUNCTION_BLOCK
END_ST