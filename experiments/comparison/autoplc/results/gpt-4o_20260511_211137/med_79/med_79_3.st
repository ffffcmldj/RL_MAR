FUNCTION_BLOCK CapsuleFillingMachineControl
    VAR_INPUT
        CapsuleWeight : REAL; (* Current capsule weight *)
        TargetWeight : REAL; (* Target weight to achieve *)
        CapsuleInPosition : BOOL; (* Capsule position sensor *)
        HopperEmpty : BOOL; (* Hopper empty sensor *)
    END_VAR

    VAR_OUTPUT
        FeederMotor : BOOL; (* Feeder motor control *)
        FillingMotor : BOOL; (* Filling motor control *)
        ConveyorMotor : BOOL; (* Conveyor motor control *)
        FillingInProgress : BOOL; (* Filling status *)
    END_VAR

    VAR
        State : INT; (* Current state of the machine *)
        Timer : TIME; (* Timer for state transitions *)
        ErrorFlag : BOOL; (* Error flag for handling errors *)
        Tolerance : REAL := 0.01; (* Tolerance for weight check *)
    END_VAR

    (* State Definitions *)
    CONST
        IDLE : INT := 0;
        CONVEYING : INT := 1;
        FILLING : INT := 2;
        CONVEYING_OUT : INT := 3;
    END_CONST;

    (* Initialization *)
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    State := IDLE;
    ErrorFlag := FALSE;

    (* Main Control Logic *)
    CASE State OF
        IDLE:
            IF HopperEmpty THEN
                (* Safety Check: Hopper is empty *)
                FeederMotor := FALSE;
                FillingMotor := FALSE;
                ConveyorMotor := FALSE;
                FillingInProgress := FALSE;
                RETURN;
            ELSIF CapsuleWeight >= TargetWeight THEN
                (* Weight Validation: Avoid overfilling *)
                FeederMotor := FALSE;
                FillingMotor := FALSE;
                ConveyorMotor := FALSE;
                FillingInProgress := FALSE;
                RETURN;
            ELSIF CapsuleInPosition THEN
                (* Transition to CONVEYING state *)
                State := CONVEYING;
                ConveyorMotor := TRUE;
            END_IF;

        CONVEYING:
            IF NOT CapsuleInPosition THEN
                (* Capsule reached filling station *)
                ConveyorMotor := FALSE;
                State := FILLING;
                FillingMotor := TRUE;
                FillingInProgress := TRUE;
            END_IF;

        FILLING:
            IF CapsuleWeight >= TargetWeight - Tolerance AND CapsuleWeight <= TargetWeight + Tolerance THEN
                (* Filling Completion *)
                FillingMotor := FALSE;
                State := CONVEYING_OUT;
                ConveyorMotor := TRUE;
                FillingInProgress := FALSE;
            END_IF;

        CONVEYING_OUT:
            IF NOT CapsuleInPosition THEN
                (* Capsule moved out of filling station *)
                ConveyorMotor := FALSE;
                State := IDLE;
            END_IF;
    END_CASE;

    (* Error Handling *)
    IF Timer > T#10s THEN
        ErrorFlag := TRUE; (* Set error flag if operation times out *)
    END_IF;

END_FUNCTION_BLOCK